From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [Xen-devel] xennet_start_xmit assumptions
Date: Thu, 19 Jan 2017 06:37:00 -0500
Message-ID: <20170119113700.GD22018@oracle.com>
References: <20170118153132.GB9258@oracle.com>
 <20170118192528.GA6847@char.us.oracle.com>
 <de0d7a7db4c24b46838aee7623d5d2a3@AMSPEX02CL03.citrite.net>
 <20170119111426.GA22018@oracle.com>
 <22c048f35d3845158b225d51dde33bf7@AMSPEX02CL03.citrite.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
        Wei Liu <wei.liu2@citrix.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>
To: Paul Durrant <Paul.Durrant@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:39248 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751936AbdASLhK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2017 06:37:10 -0500
Content-Disposition: inline
In-Reply-To: <22c048f35d3845158b225d51dde33bf7@AMSPEX02CL03.citrite.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (01/19/17 11:31), Paul Durrant wrote:
> Sowmini,
> 
> Yeah, it would be useful to verify any change fixes the particular
> issue you're seeing so please share the program. For the non-empty
> non-linear case I'd hope that catching this and doing a pull of some
> sensible amount of header (which might coincide with the least amount
> that netback expects to see in the first frag) would be enough.
> I can take a shot at a patch for this in the next few days; I'll add
> your 'Reported-by' so you should get cc-ed.

Sounds good, here is the test program (very basic, no error checks!).
I think you can probably massage the pf_packet code to send down a 
purely non-linear skb, I can take a look at what this involves and  
get back to you. 


#include <stdio.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/ioctl.h>
#include <netinet/in.h>
#include <net/if.h>
#include <stdio.h>
#include <errno.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <ctype.h>
#include <string.h>
#include <linux/if_packet.h>
#include <linux/if_ether.h>

int main(int argc, char *argv[])
{
        struct ifreq ifr;
        int sockfd = socket(AF_INET, SOCK_DGRAM, 0);
        struct sockaddr_ll sll;
        int fd;
        struct msghdr msg;

        bzero(&ifr, sizeof (ifr));
        strncpy(ifr.ifr_name, argv[1], sizeof(ifr.ifr_name));
        ioctl(sockfd, SIOCGIFHWADDR, &ifr);

        bzero(&sll, sizeof (sll));
        sll.sll_family = PF_PACKET;
        sll.sll_halen = ETH_ALEN;
        sll.sll_ifindex = if_nametoindex(argv[1]);
        memcpy(sll.sll_addr,  (struct sockaddr *)&(ifr.ifr_hwaddr), ETH_ALEN);

        fd = socket(PF_PACKET, SOCK_RAW, htons(ETH_P_ALL));
        bind(fd, (struct sockaddr *)&sll, sizeof(sll));
        bzero(&msg, sizeof (msg));
        msg.msg_name = (void *)&sll;
        msg.msg_namelen = sizeof (struct sockaddr_ll);
        sendmsg(fd, &msg, 0);
        fprintf(stderr, "sent!\n");
}
