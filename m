From: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: nl80211 NULL pointer dereference
Date: Tue, 18 Jun 2013 16:24:57 -1000
Message-ID: <CA+55aFz=eG5-zh1toHxrx=4Qm4DvwyiBCU3u-6tc0-utfZ6xiA@mail.gmail.com>
References: <CA+55aFxOde8n0M2=77-TQ2Ea9iz8s-e8zGFwjj6RVyMFXBgxEA@mail.gmail.com>
	<20130618.190632.33329016434510583.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	John Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Linux Wireless List <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20130618.190632.33329016434510583.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 18, 2013 at 4:06 PM, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> wrote:
>
> nl80211_set_reg() is really careful about validating which netlink
> attributes the user has specified, and either not dereferencing or
> signalling an error when NULL is seen.
>
> Hmmm...

The code disassembles to

   0: 41 0f b6 46 04       movzbl 0x4(%r14),%eax
   5: 0f b6 fb             movzbl %bl,%edi
   8: 41 88 45 14           mov    %al,0x14(%r13)
   c: 41 0f b6 46 05       movzbl 0x5(%r14),%eax
  11: 41 88 45 15           mov    %al,0x15(%r13)
  15: e8 8c c5 fe ff       callq  0xfffffffffffec5a6
  1a: 84 c0                 test   %al,%al
  1c: 75 68                 jne    0x86
  1e: 49 8b 47 20           mov    0x20(%r15),%rax
  22: 4c 8b a0 10 01 00 00 mov    0x110(%rax),%r12
  29:* 45 0f b7 34 24       movzwl (%r12),%r14d <-- trapping instruction
  2e: 41 83 ee 04           sub    $0x4,%r14d
  32: 41 83 fe 03           cmp    $0x3,%r14d
  36: 7e 0e                 jle    0x46
  38: 41 0f b7 44 24 04     movzwl 0x4(%r12),%eax

(I deleted the two first bytes. they were part of an incomplete
preceding instruction). The "call/test/jne" seems to be this paert:

        /*
         * Disable DFS master mode if the DFS region was
         * not supported or known on this kernel.
         */
        if (reg_supported_dfs_region(dfs_region))
                rd->dfs_region = dfs_region;

and then the two moves into %rax an %r12 seem to be setting up for

        nla_for_each_nested(nl_reg_rule, info->attrs[NL80211_ATTR_REG_RULES],

and then the movzwl (that traps) and the subsequent subtract seems to
be the inlined nla_len(nla), which is the "len" to the
nla_for_each_nested() -> nla_for_each_attr() macro expansion.

So it would seem that it's that

    info->attrs[NL80211_ATTR_REG_RULES]

thing that is NULL.

And yes, the code checks that for being non-NULL in at the top of the
function, but maybe there is a race with something else setting it to
NULL? There is a kzalloc(GFP_KERNEL) in between, so it doesn't even
have to be a very small race...

Hmm? I really don't know this code at all, so I'm just looking at the
source and lining up the oops...

                    Linus
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
