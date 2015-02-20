From: Christoph Schulz <develop@kristov.de>
Subject: Re: [PATCH] pppoe: Use workqueue to die properly when a PADT is
 received
Date: Fri, 20 Feb 2015 17:10:14 +0100
Message-ID: <20150220171014.3970204f0h4aebmu@berry.schulz.ip-v6.eu>
References: <1424381068-22252-1-git-send-email-simon@farnz.org.uk>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8;
 DelSp="Yes";
 format="flowed"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dan Williams <dcbw@redhat.com>,
	mostrows@gmail.com, linux-ppp@vger.kernel.org
To: Simon Farnsworth <simon@farnz.org.uk>
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <1424381068-22252-1-git-send-email-simon@farnz.org.uk>
Content-Disposition: inline
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(Cc: linux-ppp@vger.kernel.org, mostrows@gmail.com)

Hello!

Simon Farnsworth schrieb am Thu, 19 Feb 2015 21:24:28 +0000:

> When a PADT frame is received, the socket may not be in a good state to
> close down the PPP interface. The current implementation handles this by
> simply blocking all further PPP traffic, and hoping that the lack of traffic
> will trigger the user to investigate.
>
> Use schedule_work to get to a process context from which we clear down the
> PPP interface, in a fashion analogous to hangup on a TTY-based PPP
> interface. This causes pppd to disconnect immediately, and allows tools to
> take immediate corrective action.

Tested-by: Christoph Schulz <develop@kristov.de>

I tested your patch von top of 3.14.33 and 3.18.7 together with a  
slightly modified pppd based on Debian's pppd-2.4.6-3 (which is almost  
identical to pppd 2.4.7). The client now indeed receives PADT feedback  
immediately. Closing a PPPoE connection on the server side

Feb 20 16:45:44 swing local2.notice pppoe-server-wrapper[20154]:  
circ4: pppoe-server died with exit code 0, cleaning up

leads to immediate hangup on the client side:

Feb 20 16:45:44 sandbox local2.notice pppd[539]: Modem hangup

Formerly, the LCP echo timeout had to be reached. On the server side:

Feb 20 14:56:53 swing local2.notice pppoe-server-wrapper[12744]:  
circ4: pppoe-server died with exit code 0, cleaning up

On the client side:

Feb 20 14:57:01 sandbox local2.info pppd[15575]: No response to 2  
echo-requests
Feb 20 14:57:01 sandbox local2.notice pppd[15575]: Serial link appears  
to be disconnected.

Note that the short detection of the terminated link (~ 8 s) stems  
from very aggressive LCP echo settings (lcp-echo-interval "3",  
lcp-echo-failure "2"). Typically, these timeouts are much larger to  
accomodate for bad links. Often the client recognizes a dead link only  
after two to three minutes (lcp-echo-interval "30", lcp-echo-failure  
"5").

However, note also that your patch causes pppd (or rather the rp-pppoe  
plugin) to wonder about the socket closed by the kernel:

Feb 20 16:45:44 sandbox local2.err pppd[539]: Failed to disconnect  
PPPoE socket: 114 Operation already in progress

I don't fully understand the code there; it seems that the plugin  
*connects* the PPPoE session socket in order to *disconnect* it:

static void
PPPOEDisconnectDevice(void)
{
     struct sockaddr_pppox sp;

     sp.sa_family = AF_PPPOX;
     sp.sa_protocol = PX_PROTO_OE;
     sp.sa_addr.pppoe.sid = 0;
     memcpy(sp.sa_addr.pppoe.dev, conn->ifName, IFNAMSIZ);
     memcpy(sp.sa_addr.pppoe.remote, conn->peerEth, ETH_ALEN);
     if (connect(conn->sessionSocket, (struct sockaddr *) &sp,
                 sizeof(struct sockaddr_pppox)) < 0)
         error("Failed to disconnect PPPoE socket: %d %m", errno);
     close(conn->sessionSocket);
     /* don't send PADT?? */
     if (conn->discoverySocket >= 0)
         close(conn->discoverySocket);
}


Regards,
-- 
Christoph Schulz

