From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: Re: [PATCH 1/1] netfilter: Add possibility to turn off netfilters defrag per netns
Date: Mon, 9 Jan 2012 09:58:42 +0100
Message-ID: <201201090958.43017.hans.schillstrom@ericsson.com>
References: <1325664443-10320-1-git-send-email-hans.schillstrom@ericsson.com> <alpine.DEB.2.00.1201050959030.5244@blackhole.kfki.hu> <20120105141859.GA8210@1984>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	Jan Engelhardt <jengelh@medozas.de>,
	Patrick McHardy <kaber@trash.net>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20120105141859.GA8210@1984>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 05 January 2012 15:18:59 Pablo Neira Ayuso wrote:
> On Thu, Jan 05, 2012 at 10:11:28AM +0100, Jozsef Kadlecsik wrote:
> > OK, I see. Conntrack is per net namespace but it's enabled globally.
> >  
> > So at the moment I think the best solution is something like your patch 
> > variant (but the condition is wrong, it should be "&& !skb->nfct"):
> > 

Oops, I'll fix that :-)

> > --- a/net/ipv4/netfilter/nf_defrag_ipv4.c
> > +++ b/net/ipv4/netfilter/nf_defrag_ipv4.c
> > @@ -74,6 +74,14 @@ static unsigned int ipv4_conntrack_defrag(unsigned int
> > hooknum,
> > ...
> > +       const struct net_device *dev = (hooknum == NF_INET_LOCAL_OUT ?
> > +                                       out : in);
> > +
> > +       /* No defrag and not Previously seen (loopback)? */
> > +       if (dev_net(dev)->ct.sysctl_notrac_defrag && skb->nfct) {
> > +               /* Attach fake conntrack entry. as in NOTRACK */
> > +               skb->nfct = &nf_ct_untracked_get()->ct_general;
> > +               skb->nfctinfo = IP_CT_NEW;
> > +               nf_conntrack_get(skb->nfct);
> > +               return NF_ACCEPT;
> > +       }
> > ...
> 
> I prefer the sysctl option as well, the new table is too much and it
> remains too specific for this.
> 
> I wonder if we can conditionally register the sysctl only if we are
> inside one lxc container.
> 
Sure no problem, but the code will not be so nice ... 

> I'm telling this because this sysctl does not seem to make any sense
> to me outside of it.

I'm not so sure that we should make it asymetric,
but it's not a big deal.

Anyway here is a sample of the sysctl in a namespace.
It is the  "if (!net_eq(net, &init_net)) {..." that does the magic

diff --git a/net/netfilter/nf_conntrack_standalone.c b/net/netfilter/nf_conntrack_standalone.c
index 885f5ab..2a0d530 100644
--- a/net/netfilter/nf_conntrack_standalone.c
+++ b/net/netfilter/nf_conntrack_standalone.c
@@ -454,6 +454,21 @@ static ctl_table nf_ct_sysctl_table[] = {
        },
        { }
 };
+#define NFCT_SYSCTL_LAST \
+       ((sizeof(nf_ct_sysctl_table) / sizeof(struct ctl_table)) - 1)
+/*
+ * Not Visible in root name space (init_net)
+ */
+static ctl_table nf_ct_sysctl_ns_table[] = {
+               {
+                       .procname       = "nf_conntrack_nodefrag",
+                       .data           = &init_net.ct.sysctl_nodefrag,
+                       .maxlen         = sizeof(int),
+                       .mode           = 0644,
+                       .proc_handler   = proc_dointvec,
+               },
+               { }
+};

 #define NET_NF_CONNTRACK_MAX 2089

@@ -483,9 +498,10 @@ static int nf_conntrack_standalone_init_sysctl(struct net *net)
                if (!nf_ct_netfilter_header)
                        goto out;
        }
+       table = kzalloc(sizeof(nf_ct_sysctl_table) +
+                       sizeof(nf_ct_sysctl_ns_table), GFP_KERNEL);
+       memcpy(table, nf_ct_sysctl_table, sizeof(nf_ct_sysctl_table));

-       table = kmemdup(nf_ct_sysctl_table, sizeof(nf_ct_sysctl_table),
-                       GFP_KERNEL);
        if (!table)
                goto out_kmemdup;

@@ -494,6 +510,12 @@ static int nf_conntrack_standalone_init_sysctl(struct net *net)
        table[3].data = &net->ct.sysctl_checksum;
        table[4].data = &net->ct.sysctl_log_invalid;

+       if (!net_eq(net, &init_net)) {
+               memcpy(&table[NFCT_SYSCTL_LAST], nf_ct_sysctl_ns_table,
+                      sizeof(nf_ct_sysctl_ns_table));
+               table[NFCT_SYSCTL_LAST].data = &net->ct.sysctl_nodefrag;
+       }
+
        net->ct.sysctl_header = register_net_sysctl_table(net,
                                        nf_net_netfilter_sysctl_path, table);
        if (!net->ct.sysctl_header)
--
1.7.2.3

-- 
Regards
Hans Schillstrom <hans.schillstrom@ericsson.com>
