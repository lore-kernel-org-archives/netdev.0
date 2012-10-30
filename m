From: Krzysztof Mazur <krzysiek@podlesie.net>
Subject: Re: [PATCH v2 1/3] pppoatm: don't send frames to destroyed vcc
Date: Tue, 30 Oct 2012 21:19:37 +0100
Message-ID: <20121030201937.GA9583@shrek.podlesie.net>
References: <1350926091-12642-1-git-send-email-krzysiek@podlesie.net>
 <1351589700.17077.31.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1351589700.17077.31.camel@shinybook.infradead.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 30, 2012 at 09:35:00AM +0000, David Woodhouse wrote:
> On Mon, 2012-10-22 at 19:14 +0200, Krzysztof Mazur wrote:
> > Now pppoatm_send(), like vcc_sendmsg(), checks for vcc flags that
> > indicate that vcc is not ready.
> 
> I note that vcc_sendmsg() also checks for sock->state == SS_CONNECTED.
> Is that check not needed here? Otherwise, looks sane enough.
> 
> Acked-By: David Woodhouse <David.Woodhouse@intel.com>

I don't think so. We never leave SS_CONNECTED state. This check is
done in vcc_sendmsg() because it's called from userspace.

However maybe we should check socket state before assigning vcc to
pppoatm (untested):

diff --git a/net/atm/pppoatm.c b/net/atm/pppoatm.c
index 0dcb5dc..df06d14 100644
--- a/net/atm/pppoatm.c
+++ b/net/atm/pppoatm.c
@@ -414,6 +414,8 @@ static int pppoatm_ioctl(struct socket *sock, unsigned int cmd,
 			return -ENOIOCTLCMD;
 		if (!capable(CAP_NET_ADMIN))
 			return -EPERM;
+		if (sock->state != SS_CONNECTED)
+			return -EINVAL;
 		return pppoatm_assign_vcc(atmvcc, argp);
 		}
 	case PPPIOCGCHAN:

Thanks.

Krzysiek
