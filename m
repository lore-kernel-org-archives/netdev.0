From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RTNETLINK] Provide real oif
Date: Wed, 03 Dec 2003 21:35:03 +1100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1ARULX-0000Ny-00@gondolin.me.apana.org.au>
References: <1070410097.1038.27.camel@jzny.localdomain>
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca, netdev@oss.sgi.com
In-Reply-To: <1070410097.1038.27.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal <hadi@cyberus.ca> wrote:
>> 
>> Without the real oif you will see entries like this in the output of
>> ip r l c:
>> 
>> 192.168.0.7 dev eth0  src 192.168.0.6
>>     cache  mtu 1500 advmss 1460 metric10 64
>> 192.168.0.7 dev eth0  src 192.168.0.6
>>     cache  mtu 1500 advmss 1460 metric10 64
>> 
>> One of those has oif == 0 while the other one has oif == eth0.
>> 
> 
> They both seem to have an oif of eth0, no? 

They both have an RTA_OIF of eth0.  But RTA_OIF != rt->fl.oif.  In fact,
RTA_OIF is the value of rt->u.dst.dev.

Perhaps a program would be easier to understand.  Run the attached program
with the arguments x.x.x.x eth0, assuming that x.x.x.x is routed via
eth0 on your system.  You should then see the apparent duplicate entries
in your routing cache.

Cheers,
-- 
Debian GNU/Linux 3.0 is out! ( http://www.debian.org/ )
Email:  Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/ioctl.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <net/if.h>
#include <string.h>

int main(int argc, char **argv)
{
	struct sockaddr_in addr;
	int s;
	char msg = 0;
	int true = 1;
	struct {
		struct cmsghdr hdr;
		struct in_pktinfo pktinfo;
	} ctrl;
	struct ifreq req;
	struct msghdr hdr;
	struct iovec iov;

	if (argc < 3)
		return 1;

	addr.sin_family = AF_INET;
	inet_aton(argv[1], &addr.sin_addr);
	addr.sin_port = ntohs(30000);

	memset(&ctrl.pktinfo, 0, sizeof(ctrl.pktinfo));
	ctrl.hdr.cmsg_len = sizeof(ctrl);
	ctrl.hdr.cmsg_level = SOL_IP;
	ctrl.hdr.cmsg_type = IP_PKTINFO;

	strcpy(req.ifr_name, argv[2]);

	iov.iov_base = &msg;
	iov.iov_len = 1;

	hdr.msg_name = &addr;
	hdr.msg_namelen = sizeof(addr);
	hdr.msg_iov = &iov;
	hdr.msg_iovlen = 1;
	hdr.msg_control = &ctrl;
	hdr.msg_controllen = sizeof(ctrl);
	hdr.msg_flags = 0;

	s = socket(AF_INET, SOCK_DGRAM, 0);
	setsockopt(s, SOL_IP, IP_PKTINFO, &true, sizeof(true));

	ioctl(s, SIOCGIFINDEX, &req);
	ctrl.pktinfo.ipi_ifindex = req.ifr_ifindex;

	sendto(s, &msg, 1, 0, (struct sockaddr *)&addr, sizeof(addr));
	sendmsg(s, &hdr, 0);
	return 0;
}
