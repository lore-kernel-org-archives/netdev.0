From: "David S. Miller" <davem@davemloft.net>
Subject: Re: generic 802.11 stack
Date: Fri, 1 Oct 2004 15:53:10 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041001155310.515ee09e.davem@davemloft.net>
References: <200408312111.02438.vda@port.imtp.ilyichevsk.odessa.ua>
	<200409290910.13201.vkondra@mail.ru>
	<20040929080011.GO30131@ruslug.rutgers.edu>
	<200410011630.59465.vkondra@mail.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, mcgrof@studorgs.rutgers.edu,
        acx100-devel@lists.sourceforge.net, prism54-devel@prism54.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Vladimir Kondratiev <vkondra@mail.ru>
In-Reply-To: <200410011630.59465.vkondra@mail.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Why this change?

-extern void hh_data_is_too_small(void);
+static void hh_data_is_too_small(void)
+{
+    printk(KERN_ERR "hh_data_is_too_small\n");
+}

We don't define the function because it is meant to
cause a compile time error if hh->hh_data is too small to
hold the full p80211_data_header structure.  Please undo
this change.

And therefore undo this change too:

-	if (sizeof(hh->hh_data) < sizeof(*p))
+	if (sizeof(hh->hh_data) < sizeof(*p)) {
 		hh_data_is_too_small();
+        return -1;
+    }

Next, what's this?

-	dev->hard_header	= p80211_header;
+	dev->hard_header    	= p80211_header;
 	dev->rebuild_header 	= p80211_rebuild_header;

Your merely changing the tab character after dev->hard_header
into spaces.  Please don't do this.  This makes a lot of white
space noise when making diffs against the original davem-p80211
code thus making it harder to review the changes you actually made.

Next:

+    dev->mtu                = 2304;
+    dev->type               = ARPHRD_IEEE80211;

Is this really the correct default MTU for wireless devices?

@@ -342,7 +343,7 @@ int p80211_recv_cfackpoll(struct sk_buff
 static struct packet_type p80211_packet_type = {
 	.type	=	__constant_htons(ETH_P_802_11),
 	.func	=	p80211_rcv,
-	.data	=	(void *) 1, /* understands shared SKBs */
+	.af_packet_priv	=	(void *) 1, /* understands shared SKBs */
 };
 
You can just remove this line entirely for 2.6.x kernels.

Otherwise looks fine :-)
