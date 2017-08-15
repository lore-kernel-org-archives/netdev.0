From: =?UTF-8?Q?Pawe=c5=82_Staszewski?= <pstaszewski@itcare.pl>
Subject: 100% CPU load when generating traffic to destination network that
 nexthop is not reachable
Date: Tue, 15 Aug 2017 18:30:12 +0200
Message-ID: <177465a0-aaba-4063-e451-ebbf46728b77@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp19.iq.pl ([86.111.242.224]:55388 "EHLO smtp19.iq.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753038AbdHOQbT (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 15 Aug 2017 12:31:19 -0400
Received: from [192.168.2.200] (unknown [185.78.72.19])
        (Authenticated sender: pstaszewski@itcare.pl)
        by smtp.iq.pl (Postfix) with ESMTPSA id 3xWyfG0gLdz3xB4
        for <netdev@vger.kernel.org>; Tue, 15 Aug 2017 18:31:18 +0200 (CEST)
Content-Language: pl
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi


Doing some tests i discovered that when traffic is send by pktgen to 
forwarding host where nexthop for destination network on forwarding 
router is not reachable i have 100% cpu on all cores and perf top show 
mostly:

     77.19%  [kernel]            [k] queued_spin_lock_slowpath
     10.20%  [kernel]            [k] acpi_processor_ffh_cstate_enter
      1.41%  [kernel]            [k] queued_write_lock_slowpath


Configuration of forwarding host below:

ip a

Receiving interface:

8: enp175s0f0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state 
UP group default qlen 1000
     link/ether 0c:c4:7a:d8:5d:1c brd ff:ff:ff:ff:ff:ff
     inet 10.0.0.1/30 scope global enp175s0f0
        valid_lft forever preferred_lft forever
     inet6 fe80::ec4:7aff:fed8:5d1c/64 scope link
        valid_lft forever preferred_lft forever

Transmitting vlans (binded to: enp175s0f1)
12: vlan1000@enp175s0f1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 
qdisc noqueue state UP group default qlen 1000
     link/ether 0c:c4:7a:d8:5d:1d brd ff:ff:ff:ff:ff:ff
     inet 10.10.0.1/30 scope global vlan1000
        valid_lft forever preferred_lft forever
     inet6 fe80::ec4:7aff:fed8:5d1d/64 scope link
        valid_lft forever preferred_lft forever
13: vlan1001@enp175s0f1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 
qdisc noqueue state UP group default qlen 1000
     link/ether 0c:c4:7a:d8:5d:1d brd ff:ff:ff:ff:ff:ff
     inet 10.10.1.1/30 scope global vlan1001
        valid_lft forever preferred_lft forever
     inet6 fe80::ec4:7aff:fed8:5d1d/64 scope link
        valid_lft forever preferred_lft forever
14: vlan1002@enp175s0f1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 
qdisc noqueue state UP group default qlen 1000
     link/ether 0c:c4:7a:d8:5d:1d brd ff:ff:ff:ff:ff:ff
     inet 10.10.2.1/30 scope global vlan1002
        valid_lft forever preferred_lft forever
     inet6 fe80::ec4:7aff:fed8:5d1d/64 scope link
        valid_lft forever preferred_lft forever

Routing table:
10.0.0.0/30 dev enp175s0f0 proto kernel scope link src 10.0.0.1
10.10.0.0/30 dev vlan1000 proto kernel scope link src 10.10.0.1
10.10.1.0/30 dev vlan1001 proto kernel scope link src 10.10.1.1
10.10.2.0/30 dev vlan1002 proto kernel scope link src 10.10.2.1
172.16.0.0/24 via 10.10.0.2 dev vlan1000
172.16.1.0/24 via 10.10.1.2 dev vlan1001
172.16.2.0/24 via 10.10.2.2 dev vlan1002


pktgen is transmitting packets to this forwarding hosts and generating 
random destinations from ip range:
     pg_set $dev "dst_min 172.16.0.1"
     pg_set $dev "dst_max 172.16.2.255"


So when packets with destination network 172.16.0.0/24 are reaching 
forwarding host then are routed via  10.10.0.2 dev vlan1000
for packets with destination network 172.16.1.0/24 forwarding host 
routing them via 10.10.1.2 dev vlan1001
and last network 172.16.2.0/24 is routed via 10.10.2.2 dev vlan1002


Normally when situation is like this:

ip neigh ls dev vlan1000
10.10.0.2 lladdr ac:1f:6b:2c:18:89 REACHABLE
ip neigh ls dev vlan1001
10.10.1.2 lladdr ac:1f:6b:2c:18:89 REACHABLE
ip neigh ls dev vlan1002
10.10.2.2 lladdr ac:1f:6b:2c:18:89 REACHABLE


There is no problem router is receiving 11Mpps and forwarding then 
equally to vlans:
  bwm-ng v0.6.1 (probing every 1.000s), press 'h' for help
   input: /proc/net/dev type: rate
   -         iface                   Rx Tx                Total
==============================================================================
          vlan1002:            0.00 P/s       3877006.00 P/s 3877006.00 P/s
          vlan1001:            0.00 P/s       3877234.75 P/s 3877234.75 P/s
        enp175s0f0:     11962601.00 P/s             0.00 P/s 11962601.00 P/s
          vlan1000:            0.00 P/s       3862602.00 P/s 3862602.00 P/s
------------------------------------------------------------------------------
             total:     11962601.00 P/s      11616843.00 P/s 23579444.00 P/s



And perf top shows like this:
    PerfTop:  210522 irqs/sec  kernel:99.7%  exact:  0.0% [4000Hz 
cycles],  (all, 56 CPUs)
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

     26.98%  [kernel]       [k] do_raw_spin_lock
      7.69%  [kernel]       [k] acpi_processor_ffh_cstate_enter
      4.92%  [kernel]       [k] fib_table_lookup
      4.28%  [mlx5_core]    [k] mlx5e_xmit
      4.01%  [mlx5_core]    [k] mlx5e_handle_rx_cqe
      2.71%  [kernel]       [k] virt_to_head_page
      2.21%  [kernel]       [k] tasklet_action
      1.87%  [mlx5_core]    [k] mlx5_eq_int
      1.58%  [kernel]       [k] ipt_do_table
      1.55%  [mlx5_core]    [k] mlx5e_poll_tx_cq
      1.53%  [kernel]       [k] irq_entries_start
      1.48%  [kernel]       [k] __dev_queue_xmit
      1.44%  [kernel]       [k] __build_skb
      1.30%  [mlx5_core]    [k] eq_update_ci
      1.20%  [kernel]       [k] read_tsc
      1.10%  [kernel]       [k] ip_finish_output2
      1.06%  [kernel]       [k] ip_rcv
      1.02%  [kernel]       [k] netif_skb_features
      1.01%  [mlx5_core]    [k] mlx5_cqwq_get_cqe
      0.95%  [kernel]       [k] __netif_receive_skb_core



But when i will disable any vlan on the switch - for example I will do 
this for vlan1002
(Forwarding host is connected thru switch where are vlans to the sink host)
root@cumulus:~# ip link set down dev vlan1002.49
root@cumulus:~# ip link set down dev vlan1002.3
root@cumulus:~# ip link set down dev brtest1002

Wait for fdb to expire on switch.

there is incomplete arp on interface vlan1002
ip neigh ls dev vlan1002
10.10.2.2  INCOMPLETE


pktgen is still pushing traffic with packets that destination network is 
172.16.2.0/24




and we have 100% cpu with pps below:
   bwm-ng v0.6.1 (probing every 0.500s), press 'h' for help
   input: /proc/net/dev type: rate
   |         iface                   Rx Tx                Total
==============================================================================
          vlan1002:            0.00 P/s             1.99 P/s             
1.99 P/s
          vlan1001:            0.00 P/s        717227.12 P/s 717227.12 P/s
        enp175s0f0:      2713679.25 P/s             0.00 P/s 2713679.25 P/s
          vlan1000:            0.00 P/s        716145.44 P/s 716145.44 P/s
------------------------------------------------------------------------------
             total:      2713679.25 P/s       1433374.50 P/s 4147054.00 P/s


with perf top:



    PerfTop:  218506 irqs/sec  kernel:99.7%  exact:  0.0% [4000Hz 
cycles],  (all, 56 CPUs)
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

     91.45%  [kernel]            [k] queued_spin_lock_slowpath
      1.71%  [kernel]            [k] queued_write_lock_slowpath
      0.46%  [kernel]            [k] ip_finish_output2
      0.44%  [mlx5_core]         [k] mlx5e_handle_rx_cqe
      0.43%  [kernel]            [k] fib_table_lookup
      0.40%  [kernel]            [k] do_raw_spin_lock
      0.35%  [kernel]            [k] __neigh_event_send
      0.33%  [kernel]            [k] dst_release
      0.26%  [kernel]            [k] queued_write_lock
      0.22%  [mlx5_core]         [k] mlx5_cqwq_get_cqe
      0.22%  [mlx5_core]         [k] mlx5e_xmit
      0.19%  [kernel]            [k] virt_to_head_page
      0.18%  [kernel]            [k] page_frag_free
[...]
