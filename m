From: Jon Masters <jonathan@jonmasters.org>
Subject: Re: PROBLEM: reproducible crash KVM+nf_conntrack all recent 2.6
 kernels
Date: Fri, 29 Jan 2010 16:51:31 -0500
Message-ID: <1264801891.2793.426.camel@tonnant>
References: <1264657559.2793.103.camel@tonnant>
	 <1264658364.2793.105.camel@tonnant>  <4B6180D1.6050609@trash.net>
	 <1264720891.2793.205.camel@tonnant>  <1264727492.2793.207.camel@tonnant>
	 <1264754565.2793.405.camel@tonnant>
	 <1264756232.3184.10.camel@edumazet-laptop>
	 <1264762655.2793.409.camel@tonnant>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, netfilter-devel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1264762655.2793.409.camel@tonnant>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2010-01-29 at 05:57 -0500, Jon Masters wrote:
> On Fri, 2010-01-29 at 10:10 +0100, Eric Dumazet wrote:
> 
> > Jon, do you have multiple network namespace active on your machine, when
> > crash occurs ?
> 
> I don't believe so. I just built in Jason's latest kgdb/kdb patches and
> am going to give them a whirl to see if I can get anything more out of
> this panic than I currently have.

So, the latest crash was in here:

/* delete all expectations for this conntrack */
void nf_ct_remove_expectations(struct nf_conn *ct)
{
        struct nf_conn_help *help = nfct_help(ct);
        struct nf_conntrack_expect *exp;
        struct hlist_node *n, *next;

        /* Optimization: most connection never expect any others. */
        if (!help)
                return;

        hlist_for_each_entry_safe(exp, n, next, &help->expectations,
lnode) {
                if (del_timer(&exp->timeout)) {
                        nf_ct_unlink_expect(exp);
                        nf_ct_expect_put(exp);
                }
        }
}
EXPORT_SYMBOL_GPL(nf_ct_remove_expectations);

Specifically, in that hlist_for_each_entry_safe iteration, the list of
expectations is already NULL:

    at net/netfilter/nf_conntrack_expect.c:174
174             hlist_for_each_entry_safe(exp, n, next,
&help->expectations, lnode) {

(gdb) bt
#0  nf_ct_remove_expectations (ct=<value optimized out>)
    at net/netfilter/nf_conntrack_expect.c:174
#1  0xffffffff813e4db9 in destroy_conntrack (nfct=0xffffffff81b04e60)
    at net/netfilter/nf_conntrack_core.c:202
#2  0xffffffff813e2af8 in nf_conntrack_destroy (nfct=<value optimized
out>)
    at net/netfilter/core.c:243
#3  0xffffffff813bc209 in nf_conntrack_put (skb=0xffff88018fb97f00)
    at include/linux/skbuff.h:1924
#4  skb_release_head_state (skb=0xffff88018fb97f00) at
net/core/skbuff.c:402
#5  0xffffffff813bbf6b in skb_release_all (skb=0xffff88018fb97f00)
    at net/core/skbuff.c:420
#6  __kfree_skb (skb=0xffff88018fb97f00) at net/core/skbuff.c:435
#7  0xffffffff813bc070 in kfree_skb (skb=0xffff88018fb97f00)
    at net/core/skbuff.c:456
#8  0xffffffffa03fa0a1 in ?? ()
#9  0x0000000000000050 in ?? ()
#10 0xffff8801de810780 in ?? ()
#11 0x0000000000000000 in ?? ()

(gdb) frame 1
#1  0xffffffff813e4db9 in destroy_conntrack (nfct=0xffffffff81b04e60)
    at net/netfilter/nf_conntrack_core.c:202
202             nf_ct_remove_expectations(ct);
(gdb) print ct
$5 = (struct nf_conn *) 0xffffffff81b04e60
(gdb) print ct->
ct_general  ext         mark        proto       status      tuplehash
ct_net      lock        master      secmark     timeout     

(gdb) print ct->ext
$10 = (struct nf_ct_ext *) 0xffff8801de3369c0

(gdb) print (struct nf_conn_help *)(ct->ext +
ct->ext->offset[NF_CT_EXT_HELPER]) 
$22 = (struct nf_conn_help *) 0xffff8801de337a40

(gdb) print $22->helper
$23 = (struct nf_conntrack_helper *) 0xffff8801de337a00
(gdb) print $22->help
$24 = {ct_ftp_info = {seq_aft_nl = {{0, 0}, {269970752, 4294936578}}, 
    seq_aft_nl_num = {323805184, 32555}}, ct_pptp_info = {
    sstate = PPTP_SESSION_NONE, cstate = PPTP_CALL_NONE, pac_call_id =
27968, 
    pns_call_id = 4119, keymap = {0x7f2b134ce000, 0xb65e2965}}, 
  ct_h323_info = {sig_port = {0, 0}, rtp_port = {{0, 0}, {27968, 4119},
{
        34818, 65535}, {57344, 4940}}, {timeout = 32555, tpkt_len =
{32555, 
        0}}}, ct_sane_info = {state = SANE_STATE_NORMAL}, ct_sip_info =
{
    register_cseq = 0, invite_cseq = 0}}
(gdb) print $22->expectations
$25 = {first = 0x0}
(gdb) print $22->expecting
$26 = "\000\000"

(gdb) print $22->helper->hnode
$28 = {next = 0xffff8801de3379c0, pprev = 0x0}

(gdb) print $22->helper->name
$31 = 0xffff880210176d40 "\300\235\363\020\002\210\377\377\020\027\b\022
\002\210\377\377p\236\363\020\002\210\377\377T", <incomplete sequence
\337>
(gdb) print $22->helper->me
$32 = (struct module *) 0x7f2b134cf000

(gdb) print $22->helper->tuple 
$36 = {src = {u3 = {all = {0, 0, 0, 0}, ip = 0, ip6 = {0, 0, 0, 0}, in =
{
        s_addr = 0}, in6 = {in6_u = {u6_addr8 = '\000' <repeats 15
times>, 
          u6_addr16 = {0, 0, 0, 0, 0, 0, 0, 0}, u6_addr32 = {0, 0, 0,
0}}}}, 
    u = {all = 0, tcp = {port = 0}, udp = {port = 0}, icmp = {id = 0},
dccp = {
        port = 0}, sctp = {port = 0}, gre = {key = 0}}, l3num = 0}, dst
= {
    u3 = {all = {0, 3727915520, 4294936577, 0}, ip = 0, ip6 = {0,
3727915520, 
        4294936577, 0}, in = {s_addr = 0}, in6 = {in6_u = {
          u6_addr8 = "\000\000\000\000\000z3\336\001\210\377\377\000\000
\000", 
          u6_addr16 = {0, 0, 31232, 56883, 34817, 65535, 0, 0},
u6_addr32 = {
            0, 3727915520, 4294936577, 0}}}}, u = {all = 0, tcp = {port
= 0}, 
      udp = {port = 0}, icmp = {type = 0 '\000', code = 0 '\000'}, dccp
= {
        port = 0}, sctp = {port = 0}, gre = {key = 0}}, protonum = 0
'\000', 
    dir = 0 '\000'}}

Jon.


