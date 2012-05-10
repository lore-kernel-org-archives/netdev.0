From: Ian Campbell <Ian.Campbell-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 9/9] sunrpc: use SKB fragment destructors to delay
 completion until page is released by network stack.
Date: Thu, 10 May 2012 14:26:12 +0100
Message-ID: <1336656372.7098.123.camel@zakaz.uk.xensource.com>
References: <1336056915.20716.96.camel@zakaz.uk.xensource.com>
	 <1336056971-7839-9-git-send-email-ian.campbell@citrix.com>
	 <20120510111948.GA9609@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-TVV/8epBSDeywCmlzimD"
Cc: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Neil Brown <neilb-l3A5Bk7waGM@public.gmane.org>,
	"J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	"linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120510111948.GA9609-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

--=-TVV/8epBSDeywCmlzimD
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit

On Thu, 2012-05-10 at 12:19 +0100, Michael S. Tsirkin wrote:
> On Thu, May 03, 2012 at 03:56:11PM +0100, Ian Campbell wrote:
> > diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
> > index f6d8c73..1145929 100644
> > --- a/net/sunrpc/svcsock.c
> > +++ b/net/sunrpc/svcsock.c
> > @@ -198,7 +198,8 @@ int svc_send_common(struct socket *sock, struct xdr_buf *xdr,
> >  	while (pglen > 0) {
> >  		if (slen == size)
> >  			flags = 0;
> > -		result = kernel_sendpage(sock, *ppage, NULL, base, size, flags);
> > +		result = kernel_sendpage(sock, *ppage, xdr->destructor,
> > +					 base, size, flags);
> >  		if (result > 0)
> >  			len += result;
> >  		if (result != size)
> 
> So I tried triggering this by simply creating an nfs export on localhost
> and copying a large file out with dd, but this never seems to trigger
> this code.
> 
> Any idea how to test?

My test code, which is a bit overly complex for this because it also
tries to demonstrate corruption on the wire, is attached.

Using dd I suspect you probably need to increase the block size, and
possibly enable O_DIRECT (conv=direct?)

My typical scenario has been to mount a remote NFS and run
tcpdump -s 4096 -x -ne -v -i eth0 'host $client and ip[184:4] == 0x55555555'
to watch for on-wire corruption.

FYI I've triggered a BUG_ON in my local debug patches with your series
applied, I'm just investigating whether its my debugging or something in
the series which causes it.

After that I'll try it with local NFS and VMs with bridging etc to test
the extra aspects which your series is exercising.

Ian.

--=-TVV/8epBSDeywCmlzimD
Content-Disposition: attachment; filename="blktest3.c"
Content-Type: text/x-csrc; name="blktest3.c"; charset="UTF-8"
Content-Transfer-Encoding: 7bit

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <sys/types.h>
#include <sys/stat.h>
#include <sys/mman.h>

#include <fcntl.h>

#include <err.h>
#include <errno.h>

#define NR 256
#define SIZE 4096

int main(int argc, char **argv)
{
	int fd, rc, n, iter = 0;
	const char *path;
	static unsigned char  __attribute__ ((aligned (4096))) buf[NR][SIZE];

	if (argc != 2) {
		fprintf(stderr, "usage: blktest2 [PATH]\n");
		exit(1);
	}
	path = argv[1];

	printf("opening %s for O_DIRECT access\n", path);
	fd = open(path, O_CREAT/*|O_DIRECT*/|O_RDWR, 0666);
	if (fd < 0)
		err(1,"unable to open file");

	while(1) {
		if ((iter%10)==0)
			printf("iteration %d ...", iter);
		if (lseek(fd, (iter%NR)*SIZE, SEEK_SET) < 0)
			err(1, "seek for write %d %d\n", iter, n);
		memset(buf[iter%NR], 0xaa, SIZE);
		rc = write(fd, buf[iter%NR], SIZE);
		memset(buf[iter%NR], 0x55, SIZE);
		if (rc == -1)
			//warn("write failed");
			err(1, "write failed");
		else if (rc != SIZE)
			err(1, "only wrote %d/%d bytes\n", rc, SIZE);
		if ((iter%10)==0)
			printf("\n", iter);

		iter++;
	}
}

--=-TVV/8epBSDeywCmlzimD--
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
