From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 7/7] netfilter: nf_ct_helper: Fix logging for dropped
 packets
Date: Mon, 18 Feb 2013 23:51:07 -0800
Message-ID: <1361260267.5920.15.camel@joe-AO722>
References: <1361232651-5626-1-git-send-email-pablo@netfilter.org>
	 <1361232651-5626-8-git-send-email-pablo@netfilter.org>
	 <1361233322.2046.3.camel@joe-AO722> <20130219011109.GA6362@localhost>
	 <1361237594.2046.16.camel@joe-AO722> <20130219015015.GA11869@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	netfilter-devel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20130219015015.GA11869@localhost>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2013-02-19 at 02:50 +0100, Pablo Neira Ayuso wrote:
> On Mon, Feb 18, 2013 at 05:33:14PM -0800, Joe Perches wrote:
> > On Tue, 2013-02-19 at 02:11 +0100, Pablo Neira Ayuso wrote:
> > > On Mon, Feb 18, 2013 at 04:22:02PM -0800, Joe Perches wrote:
> > > > On Tue, 2013-02-19 at 01:10 +0100, pablo@netfilter.org wrote:
> > > > > This patch modifies the existing code to provide more specific
> > > > > error message in the scope of each helper to help users to debug
> > > > > the reason why the packet has been dropped, ie:
> > > > []
> > > > > diff --git a/include/net/netfilter/nf_conntrack_helper.h b/include/net/netfilter/nf_conntrack_helper.h
> > > > []
> > > > > @@ -100,6 +100,9 @@ struct nf_ct_helper_expectfn {
> > > > >  	void (*expectfn)(struct nf_conn *ct, struct nf_conntrack_expect *exp);
> > > > >  };
> > > > >  
> > > > > +extern void nf_ct_helper_log(struct sk_buff *skb, const struct nf_conn *,
> > > > > +			     const char *fmt, ...);

Hi again Pablo.

Sorry, I didn't look at the function implementation.

It doesn't use the var args that follow fmt.
Two current uses have format and args aren't emitted correctly.

This is needed:

From: Joe Perches <joe@perches.com>

Update nf_ct_helper_log to emit args along with the format.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/netfilter/nf_conntrack_helper.c | 11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/nf_conntrack_helper.c b/net/netfilter/nf_conntrack_helper.c
index 013cdf6..3ebc2ae 100644
--- a/net/netfilter/nf_conntrack_helper.c
+++ b/net/netfilter/nf_conntrack_helper.c
@@ -341,6 +341,13 @@ void nf_ct_helper_log(struct sk_buff *skb, const struct nf_conn *ct,
 {
 	const struct nf_conn_help *help;
 	const struct nf_conntrack_helper *helper;
+	struct va_format vaf;
+	va_list args;
+
+	va_start(args, fmt);
+
+	vaf.fmt = fmt;
+	vaf.va = &args;
 
 	/* Called from the helper function, this call never fails */
 	help = nfct_help(ct);
@@ -349,7 +356,9 @@ void nf_ct_helper_log(struct sk_buff *skb, const struct nf_conn *ct,
 	helper = rcu_dereference(help->helper);
 
 	nf_log_packet(nf_ct_l3num(ct), 0, skb, NULL, NULL, NULL,
-		      "nf_ct_%s: dropping packet: %s ", helper->name, fmt);
+		      "nf_ct_%s: dropping packet: %pV", helper->name, &vaf);
+
+	va_end(args);
 }
 EXPORT_SYMBOL_GPL(nf_ct_helper_log);
 


