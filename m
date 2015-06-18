From: Li Zhijian <lizhijian@cn.fujitsu.com>
Subject: [RFC] COLO Proxy Module
Date: Thu, 18 Jun 2015 14:37:47 +0800
Message-ID: <5582673B.3010804@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>, <pablo@netfilter.org>,
	<kaber@trash.net>, <kadlec@blackhole.kfki.hu>,
	<davem@davemloft.net>, <coreteam@netfilter.org>,
	Yang Hongyang <yanghy@cn.fujitsu.com>,
	=?UTF-8?B?5ripIOS7jua0iw==?= <wency@cn.fujitsu.com>,
	zhanghailiang <zhang.zhanghailiang@huawei.com>,
	Lai Jiangshan <laijs@cn.fujitsu.com>,
	"peter.huangpeng" <peter.huangpeng@huawei.com>,
	"Gonglei (Arei)" <arei.gonglei@huawei.com>
To: <netfilter-devel@vger.kernel.org>, <netdev@vger.kernel.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi, all

We are planning to implement a kernel module called COLO Proxy to buffer and
compare packets. This module is one of the important component of COLO project
and now it is still in early stage, so any comments and feedback are warmly
welcomed, thanks in advance.

=====
# RFC: COLO-Proxy Module

## Rationale

COLO FT/HA (COarse-grain LOck-stepping Virtual Machines for Non-stop Service)
project is a high availability solution. Both Primary VM (PVM) and Secondary VM
(SVM) run in parallel. They receive the same request from client, and generate
responses in parallel too. If the response packets from PVM and SVM are
identical, they are released immediately. Otherwise, a VM checkpoint (on demand)
is conducted.
Paper:
http://www.socc2013.org/home/program/a3-dong.pdf?attredirects=0
COLO on Xen:
http://wiki.xen.org/wiki/COLO_-_Coarse_Grain_Lock_Stepping
COLO on Qemu/KVM:
http://wiki.qemu.org/Features/COLO

By the needs of capturing response packets from PVM and SVM and finding out
whether they are identical, we introduce a new kernel module which called
colo-proxy.

This document describes the design of the colo-proxy module

## Glossary

   * PVM - Primary VM, which provides services to clients.
   * SVM - Secondary VM, a hot standby and replication of PVM.
   * PN - Primary Node, the host which PVM runs on
   * SN - Secondary Node, the host which SVM runs on

## Network topology

================================= Normal =====================================
                                  +--------+
                                  | client |
                                  +----+---+
-------------------------+           |            + -------------------------+
PN                       |           +            |                        SN|
+-------+         +----[eth0]-----[switch]-----[eth0]---------+              |
|PVM    |     +---+-+    |                        |       +---+-+            |
|     [tap0]--+ br0 |    |                        |       | br0 |            |
|       |     +-----+  [eth1]-----[forward]----[eth1]--+  +-----+            |
+-------+                |                        |    |            +-------+|
                          |                        |    |  +-----+   |    SVM||
                        [eth2]---[checkpoint]---[eth2]  +--+ br1 |-[tap0]    ||
                          |                        |       +-----+   |       ||
                          |                        |                 +-------+|
-------------------------+                        +--------------------------+
e.g.
PN:
br0: 192.168.0.33
eth1: 192.168.1.33
eth2: 192.168.2.33

SN:
br0: 192.168.0.88
br1: no ip address
eth1: 192.168.1.88
eth2: 192.168.2.88


============================== After failover ================================
                                  +--------+
                                  | client |
                                  +----+---+
-------------------------+           |            ---------------------------+
PN (dead)                |           +            |                SN (alive)|
+-------+         +----[eth0]--X--[switch]-----[eth0]-------+                |
|PVM    |     +---+-+    |                        |     +---+-+              |
|     [tap0]--+ br0 |    |                        |     | br0 +--+           |
|       |     +-----+  [eth1]--X--[forward]----[eth1]   +-----+  |           |
+-------+                |                        |              |  +-------+|
                          |                        |     +-----+  |  |    SVM||
                        [eth2]-X-[checkpoint]---[eth2]   | br1 |  +[tap0]    ||
                          |                        |     +-----+     |       ||
                          |                        |                 +-------+|
-------------------------+                        +--------------------------+

## Network flow

### Receive packets from client (Input)

                                 +------+
                                 |Client|
                                 +---+--+
+-----------------------+          |         +------------------------+
|PN                     |          v         |                      SN|
|                 +---[eth0]<---[switch]     |         +--------+     |
| +-------+       v     |                    |         |    SVM |     |
| | PVM   |     +-+-+   |                    |      [tap0]      |     |
| |     [tap0]<-+br0|   |                    |       ^ |        |     |
| |       | |   +---+   |                    |       | +--------+     |
| +-------+ |           |                    |     +-+-------------+  |
|           +-------->[eth1]------------->[eth1]--->colo-proxy     |  |
|           copy&forward|                    |     |*Adjust        |  |
|                       |                    |     | Client's ack  |  |
+-----------------------+                    +-----+---------------+--+

   * colo-proxy on SN:
     ** Capture the first ack from client, find out the initial seq number of the
        tcp connection on PVM. (for seq number adjustment)
     ** Adjust ack/sack from client until next checkpoint, make sure tcp
        connection on SVM won't break.

### Response packets (Output)

                                      +------+
                                      |Client|
                                      +---^--+
+----------------------------+          |         +------------------------+
|PN                          +          +         |                      SN|
| +----+  checkpoint   +-->[eth0]+-->[switch]     |         +---------+    |
| |PVM |     ^  |      |     +                    |         +    SVM  |    |
| +-+--+     |  v    +-+-+   |                    |      [tap0]       |    |
|   |        |[tap0]->br0|   |                    |       + +         |    |
+---v--+     |  ^    +---+   +                    +       | +---------+    |
||Vhost|     |  |        ++[eth1]<------------+[eth1]<---+v-------------+  |
+---+--+     |  |        |   +                    +      |colo-proxy    |  |
|   |     No |  |Yes     |   |                    |      |*Adjust SVM's |  |
+---|--------|--|--------|---+                    |      | Seq number   |  |
|   |     identical?     |   |                    +------+--------------+--+
| +-v-----+   ^    +-----v-+ |
| |enqueue+---+    |enqueue| |
| +-------+compare +-------+ |
|                            |
| colo-proxy                 |
+----------------------------+



   * colo-proxy on SN:
     ** track the initial seq number of the tcp connection on SVM.
        (for seq number adjustment)
     ** Adjust seq number from SVM until next checkpoint.
   * colo-proxy on PN:
     ** enqueue the packets from SVM
     ** enqueue the packets from PVM
     ** compare the tcp payload data of these two queue
     ** if the data is identical, release PVM queue, drop SVM queue
     ** if the data is not identical, notice the upper layer(userspace tools:
        QEMU or libxl on Xen) a checkpoint is needed
     ** release PVM queue and drop SVM queue at checkpoint

### After failover

At this point, PN is dead, SVM is serving the clients.

#### Receive packets from client (Input)

               +------+
               |Client|
               +---+--+
                   |
               +---v--+
               |Switch|
               +---+--+
                   v
+-------------[eth0]--------------+
|        |-------+             SN |
| +------v---------+              |
| |colo-proxy      |              |
| |*Adjust client's|              |
| | ack number     |              |
| +------+---------+              |
|        |                        |
|        |       +-----------+    |
|        |       |    SVM    |    |
|        +--->[tap0]         |    |
|                |           |    |
|                +-----------+    |
+---------------------------------+

   * colo-proxy on SN:
     ** Adjust the ack/sack number from client, this only applies to the existing
        tcp connection.

#### Response packets (Output)

               +------+
               |Client|
               +---^--+
                   |
               +---+--+
               |Switch|
               +---^--+
                   +
+-------------[eth0]--------------+
|        |-------^             SN |
| +----------------+              |
| |colo-proxy      |              |
| |*Adjust SVM's   |              |
| | seq number     |              |
| +------^---------+              |
|        |                        |
|        |       +-----------+    |
|        |       |    SVM    |    |
|        +---+[tap0]         |    |
|                |           |    |
|                +-----------+    |
+---------------------------------+

   * colo-proxy on SN:
     ** Adjust the seq number of the packets returned by SVM, this only applies
        to the existing tcp connection.

NOTE:
We track the initial seq number of the tcp connection on both PVM/SVM so that
we can calculate the offset when we do the seq adjustment after failover.

## Implementation

We archive our goal by extending nf_conntrack mechanism.

There're 4 kernel modules in colo-proxy:

### nf_conntrack_colo

In this module We add an nf_conntrack extension named 'colo':
<pre>
static struct nf_ct_ext_type nf_ct_colo_extend __read_mostly = {
      .len        = sizeof(struct nf_conn_colo),
      .move       = nf_ct_colo_extend_move,
      .destroy    = nf_ct_colo_extend_destroy,
      .align      = __alignof__(struct nf_conn_colo),
      .id		= NF_CT_EXT_COLO,
};
</pre>
This extension hold essential states needed by colo-proxy. e.g. manage the
node status, the tcp connection status.

### xt_PMYCOLO

This module is for PN. It do the following operations:

* Register a xt_target(cooperate with iptables) to initiate the PN node
    status, run a kernel thread to compare packets.
<pre>
static struct xt_target colo_primary_tg_regs[] __read_mostly = {
	{
		.name		= "PMYCOLO",
		.family		= NFPROTO_UNSPEC,
		.target		= colo_primary_tg,
		.checkentry	= colo_primary_tg_check,
		.destroy	= colo_primary_tg_destroy,
		.targetsize	= sizeof(struct xt_colo_primary_info),
		.table		= "mangle",
		.hooks		= (1 << NF_INET_PRE_ROUTING),
		.me		= THIS_MODULE,
	},
};

static int colo_primary_tg_check(const struct xt_tgchk_param *par)
{
      /*
       * Setup forward device, init primary node status, create kthread for
       * packets comparison.
       */
}
</pre>

* Register a nf_queue_handler to enqueue packets sent by PVM.
<pre>
static const struct nf_queue_handler coloqh = {
	.outfn	= &colo_enqueue_packet,
};
</pre>

* Register some nf hooks to enqueue packets sent by SVM.
<pre>
static struct nf_hook_ops colo_primary_ops[] __read_mostly = {
	{
		.hook		= colo_slaver_queue_hook,
		.owner		= THIS_MODULE,
		.pf		= NFPROTO_IPV4,
		.hooknum	= NF_INET_PRE_ROUTING,
		.priority	= NF_IP_PRI_RAW + 1,
	},
	{
		.hook		= colo_slaver_queue_hook,
		.owner		= THIS_MODULE,
		.pf		= NFPROTO_IPV6,
		.hooknum	= NF_INET_PRE_ROUTING,
		.priority	= NF_IP_PRI_RAW + 1,
	},
	{
		.hook		= colo_slaver_arp_hook,
		.owner		= THIS_MODULE,
		.pf		= NFPROTO_ARP,
		.hooknum	= NF_ARP_IN,
		.priority	= NF_IP_PRI_FILTER + 1,
	},
};
</pre>

### xt_SECCOLO

This module is for SN. It do the following operations:

* Register a xt_target(cooperate with iptables) to initiate the SN node
    status.
<pre>
static struct xt_target colo_secondary_tg_regs[] __read_mostly = {
	{
		.name		= "SECCOLO",
		.family		= NFPROTO_UNSPEC,
		.target		= colo_secondary_tg,
		.checkentry	= colo_secondary_tg_check,
		.destroy	= colo_secondary_tg_destroy,
		.targetsize	= sizeof(struct xt_colo_secondary_info),
		.table		= "mangle",
		.hooks		= (1 << NF_INET_PRE_ROUTING),
		.me		= THIS_MODULE,
	},
};
</pre>

* Register some nf hooks to track the initial seq number of the tcp
    connections on both PVM/SVM, and do the seq adjustment for SVM(by
    using the existing nf_conntrack_seqadj module).
<pre>
static struct nf_hook_ops colo_secondary_ops[] __read_mostly = {
	{
		.hook		= colo_secondary_hook,
		.owner		= THIS_MODULE,
		.pf		= NFPROTO_IPV4,
		.hooknum	= NF_INET_PRE_ROUTING,
		.priority	= NF_IP_PRI_MANGLE + 1,
	},
	{
		.hook		= colo_secondary_hook,
		.owner		= THIS_MODULE,
		.pf		= NFPROTO_IPV6,
		.hooknum	= NF_INET_PRE_ROUTING,
		.priority	= NF_IP_PRI_MANGLE + 1,
	},
};
</pre>

### nfnetlink_colo

This module is for communication with the userspace tools like QEMU or libxl.

In this module, add a colo protocol to the existing nfnetlink mechanism.
<pre>
static const struct nfnetlink_subsystem nfulnl_subsys = {
	.name		= "colo",
	.subsys_id	= NFNL_SUBSYS_COLO,
	.cb_count	= NFCOLO_MSG_MAX,
	.cb		= nfnl_colo_cb,
};

static const struct nfnl_callback nfnl_colo_cb[NFCOLO_MSG_MAX] = {
	[NFCOLO_KERNEL_NOTIFY] = { .call   = NULL,
		.policy = NULL,
		.attr_count = 0, },
	[NFCOLO_DO_CHECKPOINT] = { .call   = colo_do_checkpoint,
		.policy = nfnl_colo_policy,
		.attr_count = NFNL_COLO_MAX, },
	[NFCOLO_DO_FAILOVER] = { .call   = colo_do_failover,
		.policy = nfnl_colo_policy,
		.attr_count = NFNL_COLO_MAX, },
	[NFCOLO_PROXY_INIT] = { .call   = colo_init_proxy,
		.policy = nfnl_colo_policy,
		.attr_count = NFNL_COLO_MAX, },
	[NFCOLO_PROXY_RESET] = { .call   = colo_reset_proxy,
		.policy = nfnl_colo_policy,
		.attr_count = NFNL_COLO_MAX,},
};
</pre>

