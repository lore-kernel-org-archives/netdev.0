From: Bart De Schuymer <bdschuym@pandora.be>
Subject: Re: ipt_physdev.c alignment problems on parisc64
Date: Wed, 17 Sep 2003 23:17:38 +0200
Sender: netfilter-devel-admin@lists.netfilter.org
Message-ID: <200309172317.38348.bdschuym@pandora.be>
References: <200309022116.41697.bdschuym@pandora.be> <20030916140918.GF810@obroa-skai.de.gnumonks.org> <20030916181603.366b7c06.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: hno@marasystems.com, acme@conectiva.com.br,
	netfilter-devel@lists.netfilter.org, netdev@oss.sgi.com
Return-path: <netfilter-devel-admin@lists.netfilter.org>
To: "David S. Miller" <davem@redhat.com>,
	Harald Welte <laforge@netfilter.org>
In-Reply-To: <20030916181603.366b7c06.davem@redhat.com>
Content-Disposition: inline
Errors-To: netfilter-devel-admin@lists.netfilter.org
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: <https://lists.netfilter.org/pipermail/netfilter-devel/>
List-Id: netdev.vger.kernel.org

On Wednesday 17 September 2003 03:16, David S. Miller wrote:
> > yes. yes. yes.  The whole 'kernel internal data structure exported to
> > userspace' is a fundamental design flaw of iptables.  There's nothing we
> > can do about it, we'll have to live with it :(
>
> Why can't you change this?
>
> Just because the user gives the kernel the data in one format, this
> does not at all prevent the actual iptables kernel implementation from
> using some other structure to store the data.  You just have to translate
> things on the way in and out, that's all.

In theory this is ofcourse possible. In practice this would mean changing
ip_tables.c, which is not a good idea.

Below is a patch that does a char-by-char compare for ipt_physdev.c.
Since there have not been any reports about these alignment problems for
other similar code, I'd wait with changing any of them.
It's still not too late to apply the other patch that just aligned the
struct member instead.
Let me try to convince you one more time :)
- as Harald stated it's 2.6 only, so these userspace incompatibilities
are no problem
- it is too much trouble to get right alignment without messing up
userspace compatibility (ip_tables.c needs to be changed)
- even if the other similar device comparing code needs to be fixed, there
is no reason why ipt_physdev should be slowed down like all the rest.
- the code below is slower

It's up to you, I'm not religious about this stuff.

cheers,
Bart


--- linux-2.6.0-test5/net/ipv4/netfilter/ipt_physdev.c.old	2003-09-17 22:55:53.000000000 +0200
+++ linux-2.6.0-test5/net/ipv4/netfilter/ipt_physdev.c	2003-09-17 22:58:17.000000000 +0200
@@ -23,7 +23,7 @@ match(const struct sk_buff *skb,
 	int i;
 	static const char nulldevname[IFNAMSIZ];
 	const struct ipt_physdev_info *info = matchinfo;
-	unsigned long ret;
+	unsigned int ret;
 	const char *indev, *outdev;
 	struct nf_bridge_info *nf_bridge;
 
@@ -65,11 +65,8 @@ match(const struct sk_buff *skb,
 	if (!(info->bitmask & IPT_PHYSDEV_OP_IN))
 		goto match_outdev;
 	indev = nf_bridge->physindev ? nf_bridge->physindev->name : nulldevname;
-	for (i = 0, ret = 0; i < IFNAMSIZ/sizeof(unsigned long); i++) {
-		ret |= (((const unsigned long *)indev)[i]
-			^ ((const unsigned long *)info->physindev)[i])
-			& ((const unsigned long *)info->in_mask)[i];
-	}
+	for (i = 0, ret = 0; i < IFNAMSIZ; i++)
+		ret |= (indev[i] ^ info->physindev[i]) & info->in_mask[i];
 
 	if ((ret == 0) ^ !(info->invert & IPT_PHYSDEV_OP_IN))
 		return NOMATCH;
@@ -79,11 +76,8 @@ match_outdev:
 		return MATCH;
 	outdev = nf_bridge->physoutdev ?
 		 nf_bridge->physoutdev->name : nulldevname;
-	for (i = 0, ret = 0; i < IFNAMSIZ/sizeof(unsigned long); i++) {
-		ret |= (((const unsigned long *)outdev)[i]
-			^ ((const unsigned long *)info->physoutdev)[i])
-			& ((const unsigned long *)info->out_mask)[i];
-	}
+	for (i = 0, ret = 0; i < IFNAMSIZ; i++)
+		ret |= (outdev[i] ^ info->physoutdev[i]) & info->out_mask[i];
 
 	return (ret != 0) ^ !(info->invert & IPT_PHYSDEV_OP_OUT);
 }
