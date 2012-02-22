From: Arun Sharma <asharma@fb.com>
Subject: Re: route add default fails with ESRCH?
Date: Wed, 22 Feb 2012 11:28:37 -0800
Message-ID: <4F4541E5.5040700@fb.com>
References: <4F3F0158.2020406@fb.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="------------080105020208070309080000"
Cc: LKML <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4F3F0158.2020406@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--------------080105020208070309080000
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit

[ Expanded cc ]

On 2/17/12 5:39 PM, Arun Sharma wrote:
>
> I've been trying to debug this strange problem with recent 3.2 kernels:
>
> # boot to single user mode
> # service network start
> # ifconfig eth0
> eth0 Link encap:Ethernet HWaddr <blah>
> inet addr:10.47.46.39 Bcast:10.47.46.255 Mask:255.255.255.0
>
> <Link is up>
> # strace route add default gw 10.47.46.1
> ioctl(3, SIOCADDRT, 0x7fff1fd4db80) = -1 ESRCH (No such process)

I git bisected the problem to this commit:

commit 3630b7c050d9c3564f143d595339fc06b888d6f3
Author: David S. Miller <davem@davemloft.net>
Date: Tue Feb 1 15:15:39 2011 -0800

ipv4: Remove fib_hash.

which came in via 2.6.39.

 > If there are any semantic differences found in fib_trie, we should
 > simply fix them.

Looks like the problem I'm running into falls into this bucket (since it 
goes away if I revert the commit).

I changed the pr_debug() in fib_trie.c to pr_info() and got some debug 
output (attached).

Based on the debug info, I think it's this call that's failing with ESRCH:

[   69.189627] Insert table=254 00000000/0

/sbin/route -V
net-tools 1.60
route 1.98 (2001-04-15)

# cat /proc/net/fib_trie
Local:
   +-- 0.0.0.0/1 1 0 0
      +-- 10.47.46.0/24 1 0 0
         +-- 10.47.46.0/26 1 0 0
            |-- 10.47.46.0
               /32 link BROADCAST
            |-- 10.47.46.39
               /32 host LOCAL
         |-- 10.47.46.255
            /32 link BROADCAST
      +-- 127.0.0.0/8 1 0 0
         +-- 127.0.0.0/31 1 0 0
            |-- 127.0.0.0
               /32 link BROADCAST
               /8 host LOCAL
            |-- 127.0.0.1
               /32 host LOCAL
         |-- 127.255.255.255
            /32 link BROADCAST

Please let me know if you have any suggestions.

  -Arun

--------------080105020208070309080000
Content-Type: text/plain; name="fib_debug.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="fib_debug.txt"

[   17.445984] Insert table=255 7f000001/32
[   17.445993] AT ffff880213d0ae40 s=56 32
[   17.445997] In tnode_resize ffff880213d0ae40 inflate_threshold=50 threshold=25
[   17.446014] Insert table=255 7f000000/8
[   17.446024] AT ffff880213d0ade0 s=56 32
[   17.446026] In tnode_resize ffff880213d0ade0 inflate_threshold=50 threshold=25
[   17.446030] Insert table=255 7f000000/32
[   17.446035] Insert table=255 7fffffff/32
[   17.446038] AT ffff880213d0ad20 s=56 32
[   17.446040] In tnode_resize ffff880213d0ad20 inflate_threshold=50 threshold=25
[   17.446941] Insert table=255 7f000001/32
[   17.446944] Insert table=255 7f000000/8
[   17.446946] Insert table=255 7f000000/32
[   17.446948] Insert table=255 7fffffff/32
[   37.708794] e1000e 0000:05:00.0: irq 66 for MSI/MSI-X
[   37.761305] e1000e 0000:05:00.0: irq 66 for MSI/MSI-X
[   37.763389] ADDRCONF(NETDEV_UP): eth0: link is not ready
[   40.643385] e1000e: eth0 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: None
[   40.644668] ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
[   44.040787] Insert table=255 0a2f2e27/32
[   44.040798] AT ffff880213d45960 s=56 32
[   44.040800] In tnode_resize ffff880213d45960 inflate_threshold=50 threshold=25
[   44.040807] Insert table=255 0affffff/32
[   44.040811] AT ffff880213d45a20 s=56 32
[   44.040813] In tnode_resize ffff880213d45960 inflate_threshold=50 threshold=25
[   44.040817] Insert table=254 0a000000/8
[   44.040821] AT ffff880213d45840 s=56 32
[   44.040823] In tnode_resize ffff880213d45840 inflate_threshold=50 threshold=25
[   44.040827] Insert table=255 0a000000/32
[   44.040830] AT ffff880213d457e0 s=56 32
[   44.040831] In tnode_resize ffff880213d45a20 inflate_threshold=50 threshold=25
[   44.040833] In tnode_resize ffff880213d45960 inflate_threshold=50 threshold=25
[   44.040837] Insert table=255 0affffff/32
[   44.040886] Deleting 0a000000/8 tos=0 t=ffff880212b846a0
[   44.040889] entering trie_leaf_remove(ffff880211585070)
[   44.040891] Deleting 0affffff/32 tos=0 t=ffff880213d07d20
[   44.040894] entering trie_leaf_remove(ffff880211585038)
[   44.040895] In tnode_resize ffff880213d45a20 inflate_threshold=50 threshold=25
[   44.040897] In tnode_resize ffff880213d45960 inflate_threshold=50 threshold=25
[   44.040900] Deleting 0a000000/32 tos=0 t=ffff880213d07d20
[   44.040902] entering trie_leaf_remove(ffff8802115850a8)
[   44.040904] In tnode_resize ffff880213d457e0 inflate_threshold=50 threshold=25
[   44.040906] In tnode_resize ffff880213d45960 inflate_threshold=50 threshold=25
[   44.040908] Deleting 0a2f2e27/32 tos=0 t=ffff880213d07d20
[   44.040910] entering trie_leaf_remove(ffff880211585000)
[   44.040912] In tnode_resize ffff880213d45960 inflate_threshold=50 threshold=25
[   44.041833] Insert table=255 0a2f2e27/32
[   44.041835] AT ffff880213d45ae0 s=56 32
[   44.041837] In tnode_resize ffff880213d45ae0 inflate_threshold=50 threshold=25
[   44.041841] Insert table=255 0a2f2eff/32
[   44.041844] AT ffff880213d45720 s=56 32
[   44.041846] In tnode_resize ffff880213d45ae0 inflate_threshold=50 threshold=25
[   44.041849] Insert table=254 0a2f2e00/24
[   44.041852] AT ffff880213d45a80 s=56 32
[   44.041854] In tnode_resize ffff880213d45a80 inflate_threshold=50 threshold=25
[   44.041857] Insert table=255 0a2f2e00/32
[   44.041860] AT ffff880213d456c0 s=56 32
[   44.041862] In tnode_resize ffff880213d45720 inflate_threshold=50 threshold=25
[   44.041864] In tnode_resize ffff880213d45ae0 inflate_threshold=50 threshold=25
[   44.041868] Insert table=255 0a2f2eff/32
[   44.050950] Insert table=254 00000000/0
[   44.050961] AT ffff880213d0a5a0 s=56 32
[   44.050963] In tnode_resize ffff880213d0a5a0 inflate_threshold=50 threshold=25
[   44.351839] Deleting 00000000/0 tos=0 t=ffff880212b846a0
[   44.351843] entering trie_leaf_remove(ffff880213d120e0)
[   44.351846] In tnode_resize ffff880213d0a5a0 inflate_threshold=50 threshold=25
[   44.351852] Deleting 0a2f2e00/24 tos=0 t=ffff880212b846a0
[   44.351855] entering trie_leaf_remove(ffff880211585150)
[   69.189627] Insert table=254 00000000/0

--------------080105020208070309080000--
