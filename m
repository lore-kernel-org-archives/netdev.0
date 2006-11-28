From: David Miller <davem@davemloft.net>
Subject: Re: TCP congestion graphs (2.6.19-rc4)
Date: Tue, 28 Nov 2006 14:38:39 -0800 (PST)
Message-ID: <20061128.143839.68048301.davem@davemloft.net>
References: <7335583a0610311525h10cf4e75x42e421d3eb6f53aa@mail.gmail.com>
	<20061031161007.0fdf5c63@freekitty>
	<20061031.173028.118970335.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davidwei79@gmail.com, rhee@eos.ncsu.edu, sha2@ncsu.edu,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:8166
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1757459AbWK1Wid (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Nov 2006 17:38:33 -0500
To: shemminger@osdl.org
In-Reply-To: <20061031.173028.118970335.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem@davemloft.net>
Date: Tue, 31 Oct 2006 17:30:28 -0800 (PST)

> From: Stephen Hemminger <shemminger@osdl.org>
> Date: Tue, 31 Oct 2006 16:10:07 -0800
> 
> > On Tue, 31 Oct 2006 15:25:16 -0800
> > "Xiaoliang (David) Wei" <davidwei79@gmail.com> wrote:
> > 
> > > It seems that the default Vegas alpha parameter in the rc4 is 1...
> > > 
> > > I observed similar situation with the NS2Linux simulator (with 2.6.16
> > > code) and found that if alpha=1, delayed ack will make it broken
> > > (keeping cwnd very low without real congestion)
> > > 
> > > See details at http://www.cs.caltech.edu/%7Eweixl/technical/ns2linux/known_linux/index.html#vegas
> > > 
> > > (Basically alpha==1 means Vegas seeks to see a delay of about 1 packet
> > > worth. With delayed ack, 1 packet worth of delay is common even with
> > > no congestion.)
> > > 
> > > To make Vegas work, I'd suggest to raise alpha to at least 2 or 3.
> > > (and beta has to be at least as large as alpha.)
> > > 
> > > -David
> > > 
> > 
> > I ran with the current default:
> > 	alpha = 1 (scaled 2)
> > 	beta  = 3 (scaled 6)
> > 	gamma = 1 (scaled 2)
> 
> Testing with alpha=2 and beta=4 would be interesting.

Instead of letting this issue rot, I've checked the following into
net-2.6.20

commit cd7f265b9069d8fd66a33d37139821f84ef04f0e
Author: David S. Miller <davem@sunset.davemloft.net>
Date:   Tue Nov 28 14:37:38 2006 -0800

    [TCP] Vegas: Increase default alpha to 2 and beta to 4.
    
    This helps Vegas cope better with delayed ACKs, see
    analysis at:
    
    http://www.cs.caltech.edu/%7Eweixl/technical/ns2linux/known_linux/index.html#vegas
    
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/ipv4/tcp_vegas.c b/net/ipv4/tcp_vegas.c
index a3b7aa0..ddc4bcc 100644
--- a/net/ipv4/tcp_vegas.c
+++ b/net/ipv4/tcp_vegas.c
@@ -42,8 +42,8 @@ #include <net/tcp.h>
  * with V_PARAM_SHIFT bits to the right of the binary point.
  */
 #define V_PARAM_SHIFT 1
-static int alpha = 1<<V_PARAM_SHIFT;
-static int beta  = 3<<V_PARAM_SHIFT;
+static int alpha = 2<<V_PARAM_SHIFT;
+static int beta  = 4<<V_PARAM_SHIFT;
 static int gamma = 1<<V_PARAM_SHIFT;
 
 module_param(alpha, int, 0644);
