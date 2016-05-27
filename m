From: Sam Patton <sam@enhancedip.org>
Subject: BUG: netfilter hooks: problems porting to 4.4.6
Date: Fri, 27 May 2016 13:53:07 -0400
Message-ID: <CABvMDUemp8Zb8dv2vcQ_Mm5Wk5u5LorLc3z+hRp5HoLk-R=tjw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Did something change in Netfilter on the 4.4.6 kernel that would affect my

Netfilter hook driver?  I have a driver that works in 2.6.38, 3.10.49 and

3.15.3.   I started porting the driver to the 4.4.6 kernel and

can't get it to work.  Specifically, apply_eip_snat() in the driver never gets

called and it should get called as packets leave the NAT.  The

print statement below  where I print out maniptype is always returning 1.

e.g. NF_NAT_MANIP_DST.


Here's my iptables command:

iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE


Here's relevant code snippets.

static struct nf_hook_ops nf_nat_ops[] __read_mostly = {

      // Before packet filtering, change destination

      {

              .hook           = nf_eipnat_in,

              .owner          = THIS_MODULE,

              .pf             = PF_INET,

              .hooknum        = NF_INET_PRE_ROUTING,

              .priority       = NF_IP_PRI_NAT_DST,

      },

      // After packet filtering, change source

      {

              .hook           = nf_eipnat_out,

              .owner          = THIS_MODULE,

              .pf             = PF_INET,

              .hooknum        = NF_INET_POST_ROUTING,

              .priority       = NF_IP_PRI_NAT_SRC,

      },

};



nf_eipnat_in(unsigned int hooknum,

        struct sk_buff *skb,

        const struct net_device *in,

        const struct net_device *out,

        int (*okfn)(struct sk_buff *))

{

      printk("nf_eipnat_in\n");

      return nf_nat_fn("dnat in prerouting", hooknum, skb, in, out, okfn);

}



static unsigned int

nf_eipnat_out(unsigned int hooknum,

         struct sk_buff *skb,

         const struct net_device *in,

         const struct net_device *out,

         int (*okfn)(struct sk_buff *))

{

      printk("nf_eipnat_out\n");

      return nf_nat_fn("snat out postrouting", hooknum, skb, in, out, okfn);

}


static unsigned int

nf_nat_fn(char *instring,

        unsigned int hooknum,

        struct sk_buff *skb,

        const struct net_device *in,

        const struct net_device *out,

        int (*okfn)(struct sk_buff *))

{

      unsigned int retval = 0;


      /* maniptype == SRC for postrouting. */

      enum nf_nat_manip_type maniptype = HOOK2MANIP(hooknum);

      printk("maniptype = %d\n", maniptype);


      /* We never see fragments: conntrack defrags on pre-routing

         and local-out, and nf_nat_out protects post-routing. */

      NF_CT_ASSERT(!(ip_hdr(skb)->frag_off & htons(IP_MF | IP_OFFSET)));


      //printskb(instring, skb, in, out);

      if(maniptype == NF_NAT_MANIP_DST){

              retval = apply_eip_dnat(in, skb);

      }

      else{

              retval = apply_eip_snat(out, skb);

      }


      return retval;

}

Thanks!

-Sam
