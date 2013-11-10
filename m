From: arno@natisbad.org (Arnaud Ebalard)
Subject: [BUG,REGRESSION?] 3.11.6+,3.12: GbE iface rate drops to few KB/s
Date: Sun, 10 Nov 2013 14:53:46 +0100
Message-ID: <8761s0cqhh.fsf@natisbad.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stable@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org
To: Eric Dumazet <edumazet@google.com>, David S. Miller <davem@davemloft.net>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Hi,

I decided to upgrade the kernel on one of my ReadyNAS 102 from 3.11.1 to 
3.11.7. The device is based on Marvell Armada 370 SoC and uses mvneta
driver. Mine runs Debian armel unstable but I can confirm the issue also
happens on a debian harmhf unstable.

Doing some scp transfers of files located on the NAS (1000baseT-FD on
both side), I noticed the transfers rate is ridiculously slow (280KB/s).
I did the same test with a 3.12 kernel and got the same results,
i.e. AFAICT the bug also exist upstream.

So, I decided to go to hell and start digging a bit: I run a 'git bisect'
session on stable tree from 3.11.1 (known good) to 3.11.7 (known
bad). The results are given below.

I decided to reboot on my old 3.11.1 kernel and do 20 files transfers
of a 1GB file located on the NAS to my laptop via scp. I took the 20+
minutes and let them all finish: each transfer took between 1min5s and
1min7s (around 16MB/s, the limitation in that case being the crypto part).

I rebooted again and did the exact same thing on the 3.11.7 and after
the completion of the first file transfer in 1m6s (16MB/s), the second
one gave me that:

arno@small:~scp RN102:/tmp/random /dev/null
random                               0% 1664KB 278.9KB/s 1:05:37 ETA^C

And it continued that way for the remaining transfers (i did ^c after
some seconds to restart the transfer when the rate was low):

$ for k in $(seq 1 20) ; do scp RN102:random /dev/null ; done 
random                             100% 1024MB  15.6MB/s   01:06 ETA^C 
random                               0% 9856KB 282.2KB/s 1:01:20 ETA^C
random                              16%  168MB 563.9KB/s   25:54 ETA^C
random                               0% 2816KB 273.5KB/s 1:03:43 ETA^C
random                             100% 1024MB  15.5MB/s   01:06    
random                               1%   17MB 282.3KB/s 1:00:54 ETA^C
random                               0%  544KB 259.2KB/s 1:07:23 ETA^C
random                               0% 4224KB 277.3KB/s 1:02:45 ETA^C
random                               0%  832KB 262.1KB/s 1:06:37 ETA^C
random                               0% 3360KB 273.4KB/s 1:03:43 ETA^C
random                               0% 3072KB 271.8KB/s 1:04:07 ETA^C
random                               0%  832KB 262.1KB/s 1:06:37 ETA^C
random                               0% 1408KB 267.0KB/s 1:05:21 ETA^C
random                               0% 1120KB 264.7KB/s 1:05:57 ETA
...

To be sure, I did 2 additional reboots, one on each kernel and the
result is consistent. Perfect on 3.11.1 and slow rate most of the time
on 3.11.7 (Both kernel are compiled from a fresh make clean, using the
same config file).

Then, knowing that, I started a git bisect session on stable tree to end
up with the following suspects. I failed to go any further to a single
commit, due to crashes, but I could recompile a kernel w/ debug info and
report what I get if neeeded.

commit dc0791aee672 tcp: do not forget FIN in tcp_shifted_skb()     [bad]
commit 18ddf5127c9f tcp: must unclone packets before mangling them
commit 80bd5d8968d8 tcp: TSQ can use a dynamic limit
commit dbeb18b22197 tcp: TSO packets automatic sizing
commit 50704410d014 Linux 3.11.6                                    [good]

Eric, David, if it has already been reported and fixed, just tell
me. Otherwise, if you have any ideas, I'll be happy to test this
evening.

Cheers,

a+


Just in case it may be useful, here is what ethtool reports on RN102:

# ethtool -i eth0
driver: mvneta
version: 1.0
firmware-version: 
bus-info: eth0
supports-statistics: no
supports-test: no
supports-eeprom-access: no
supports-register-dump: no
supports-priv-flags: no

# ethtool -k eth0
Features for eth0:
rx-checksumming: off [fixed]
tx-checksumming: on
        tx-checksum-ipv4: on
        tx-checksum-ip-generic: off [fixed]
        tx-checksum-ipv6: off [fixed]
        tx-checksum-fcoe-crc: off [fixed]
        tx-checksum-sctp: off [fixed]
scatter-gather: on
        tx-scatter-gather: on
        tx-scatter-gather-fraglist: off [fixed]
tcp-segmentation-offload: off
        tx-tcp-segmentation: off [fixed]
        tx-tcp-ecn-segmentation: off [fixed]
        tx-tcp6-segmentation: off [fixed]
udp-fragmentation-offload: off [fixed]
generic-segmentation-offload: on
generic-receive-offload: on
large-receive-offload: off [fixed]
rx-vlan-offload: off [fixed]
tx-vlan-offload: off [fixed]
ntuple-filters: off [fixed]
receive-hashing: off [fixed]
highdma: off [fixed]
rx-vlan-filter: off [fixed]
vlan-challenged: off [fixed]
tx-lockless: off [fixed]
netns-local: off [fixed]
tx-gso-robust: off [fixed]
tx-fcoe-segmentation: off [fixed]
tx-gre-segmentation: off [fixed]
tx-udp_tnl-segmentation: off [fixed]
tx-mpls-segmentation: off [fixed]
fcoe-mtu: off [fixed]
tx-nocache-copy: on
loopback: off [fixed]
rx-fcs: off [fixed]
rx-all: off [fixed]
tx-vlan-stag-hw-insert: off [fixed]
rx-vlan-stag-hw-parse: off [fixed]
rx-vlan-stag-filter: off [fixed]
