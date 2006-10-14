From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [Bugme-new] [Bug 7362] New: tun/tap device needs root
	permission for TUNSETIFF ioctl
Date: Sat, 14 Oct 2006 10:22:59 +0100
Message-ID: <1160817779.13641.14.camel@pmac.infradead.org>
References: <200610132122.k9DLMmiD025915@fire-2.osdl.org>
	 <20061013144316.a8dcbc95.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: murguia@acm.org,
	"bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:6807 "EHLO
	pentafluge.infradead.org") by vger.kernel.org with ESMTP
	id S1752122AbWJNJXH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 14 Oct 2006 05:23:07 -0400
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20061013144316.a8dcbc95.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-10-13 at 14:43 -0700, Andrew Morton wrote:
> > Problem Description:
> > Applying TUNSETIFF ioctl needs root permissions that wasn't needed in previous
> > versions. I was using qemu 0.8.2 (a virtual machine emulator) which uses a tap
> > device to emulate a network between the guest and host operating system. 
> > 
 ...
> > I was handling security by limiting access to /dev/net/tun from a privileged
> > unix group, but now even if I can open the /dev/net/tun device, I need
> > CAP_NET_ADMIN to use the TUNSETIFF ioctl.
> > 
> 
> Changelog for ca6bb5d7ab22ac79f608fe6cbc6b12de6a5a19f0 says
> 
>     The tuntap driver allows an admin to create persistent devices and
>     assign ownership of them to individual users. Unfortunately, relaxing
>     the permissions on the /dev/net/tun device node so that they can
>     actually use those devices will _also_ allow those users to create
>     arbitrary new devices of their own. This patch corrects that, and
>     adjusts the recommended permissions for the device node accordingly.
> 
> So I suspect you're out of luck.

You can create the device in advance, as root. Use TUNSETPERSIST and
TUNSETOWNER ioctls to make it persistent and assign ownership of it to
the user who runs qemu. This functionality probably ought to be in
iproute2 but afaict isn't.

'ip tuntap create mode tap owner 500 persist dev tap0' would do
something like this...

#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sys/socket.h>
#include <string.h>

#include <linux/ioctl.h>
#include <linux/if.h>
#include <linux/if_tun.h>

char dev[IFNAMSIZ] = "tap0";

int main(void)
{
        struct ifreq ifr;
        int fd, err;

        if( (fd = open("/dev/net/tun", O_RDWR)) < 0 ) {
                perror("open");
                return fd;
        }

        memset(&ifr, 0, sizeof(ifr));

        /* Flags: IFF_TUN   - TUN device (no Ethernet headers)
         *        IFF_TAP   - TAP device
         *
         *        IFF_NO_PI - Do not provide packet information
         */
        ifr.ifr_flags = IFF_TAP;
        if( *dev )
                strncpy(ifr.ifr_name, dev, IFNAMSIZ);

        if( (err = ioctl(fd, TUNSETIFF, (void *) &ifr)) < 0 ){
                close(fd);
                return err;
        }
        if( (err = ioctl(fd, TUNSETPERSIST, 1)) < 0 ) {
                    perror("TUNSETPERSIST");
                close(fd);
                return err;
        }
        if( (err = ioctl(fd, TUNSETOWNER, 500)) < 0 ){
                perror("TUNSETOWNER");
                close(fd);
                return err;
        }
        strcpy(dev, ifr.ifr_name);
        printf("%s\n", ifr.ifr_name);
        sleep(10);
        return fd;
}

-- 
dwmw2

