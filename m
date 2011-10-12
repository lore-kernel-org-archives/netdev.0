From: Andras Takacs <andras.takacs@sztaki.hu>
Subject: ip6/ip6 tunnel add/change failure
Date: Wed, 12 Oct 2011 17:10:47 +0200
Message-ID: <BC6E48CC-B149-4467-AC9F-FAB71C58EFCE@sztaki.hu>
Mime-Version: 1.0 (Apple Message framework v1244.3)
Content-Type: multipart/mixed; boundary="Apple-Mail=_02DAE481-C9B7-407C-9EDA-EEC3A2C8F3BB"
Cc: =?iso-8859-1?Q?J=F3zsef_Kovacs?= <jk@sztaki.hu>,
	Emmanuel Thierry <emmanuel.thierry@telecom-bretagne.eu>,
	=?iso-8859-1?Q?Vir=E1g_L=E1szl=F3?= <lvirag@sztaki.hu>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:62147 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753113Ab1JLPKx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Oct 2011 11:10:53 -0400
Received: by eye27 with SMTP id 27so843960eye.19
        for <netdev@vger.kernel.org>; Wed, 12 Oct 2011 08:10:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--Apple-Mail=_02DAE481-C9B7-407C-9EDA-EEC3A2C8F3BB
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=iso-8859-1

Dear All,

We're using Mobile IPv6 Daemon (mip6d) on Linux 2.6.35.14. Previously we =
have used 2.6.22 without any kernel-related issues. Unfortunately this =
kernel version produces a very annoying problem with the IP6/IP6 =
tunnels. We're having two tunnels, which are linked to two different eth =
interfaces.=20

The issue: All of the packets, independently from the tunnel interface =
leaves the box via eth1 with the correct source address. Instead of the =
expected way, when the packets sent via ip6tnl1 go out on eth1, and the =
others (sent via ip6tnl2) go out on eth2.=20

We tried to reproduce this issue without mip6d, only with the ip =
command. I attached the setup and the test scripts. In this case, the =
routing works fine.

After a lot of debugging we found the following difference: mip6d =
creates the tunnel with remote address A. Later, it changes it to B. We =
found that somewhere here is the key.

1) The following data shows the internals of ip6tnl1 device's net_device =
structure. we dumped it from the rtnl_fill_ifinfo, which was triggered =
by ip -6 link ls:

Breakpoint 3, 0xc0399069 in rtnl_fill_ifinfo (skb=3D0xcee55300, =
dev=3D0xcede7000, type=3D16, pid=3D537, seq=3D1318434857, change=3D0, =
flags=3D2)
    at =
/mnt/hgfs/svnOnMyMac/SZTAKI/ITSSv6/trunk/kernel/linux-2.6.35.14/net/core/r=
tnetlink.c:1014
1014			if (tb[IFLA_ADDRESS] &&
(gdb) p *dev
$7 =3D {name =3D "ip6tnl1\000\000\000\000\000\000\000\000", pm_qos_req =3D=
 0x0, name_hlist =3D {next =3D 0x0, pprev =3D 0xcf95fac8}, ifalias =3D =
0x0, mem_end =3D 0, mem_start =3D 0, base_addr =3D 0,=20
  irq =3D 0, if_port =3D 0 '\0', dma =3D 0 '\0', state =3D 3, dev_list =3D=
 {next =3D 0xcfbd1838, prev =3D 0xcec1d038}, napi_list =3D {next =3D =
0xcede7040, prev =3D 0xcede7040}, unreg_list =3D {
    next =3D 0xcede7048, prev =3D 0xcede7048}, features =3D 8192, =
ifindex =3D 7, iflink =3D 4, stats =3D {rx_packets =3D 0, tx_packets =3D =
2, rx_bytes =3D 0, tx_bytes =3D 176, rx_errors =3D 0,=20
    tx_errors =3D 0, rx_dropped =3D 0, tx_dropped =3D 0, multicast =3D =
0, collisions =3D 0, rx_length_errors =3D 0, rx_over_errors =3D 0, =
rx_crc_errors =3D 0, rx_frame_errors =3D 0, rx_fifo_errors =3D 0,=20
    rx_missed_errors =3D 0, tx_aborted_errors =3D 0, tx_carrier_errors =3D=
 0, tx_fifo_errors =3D 0, tx_heartbeat_errors =3D 0, tx_window_errors =3D =
0, rx_compressed =3D 0, tx_compressed =3D 0},=20
  netdev_ops =3D 0xc0461c78, ethtool_ops =3D 0x0, header_ops =3D 0x0, =
flags =3D 145, gflags =3D 0, priv_flags =3D 1024, padded =3D 0, =
operstate =3D 0 '\0', link_mode =3D 0 '\0', mtu =3D 1460, type =3D 769,=20=

  hard_header_len =3D 54, needed_headroom =3D 0, needed_tailroom =3D 0, =
master =3D 0x0, perm_addr =3D '\0' <repeats 31 times>, addr_len =3D 16 =
'\020', dev_id =3D 0, addr_list_lock =3D {{rlock =3D {
        raw_lock =3D {slock =3D 1}, magic =3D 3735899821, owner_cpu =3D =
4294967295, owner =3D 0xffffffff, dep_map =3D {key =3D 0xc0b979dc, =
class_cache =3D 0xc072dd30,=20
          name =3D 0xc057b8d5 "_xmit_TUNNEL6"}}, {__padding =3D =
"\001\000\000\000?N??????????", dep_map =3D {key =3D 0xc0b979dc, =
class_cache =3D 0xc072dd30,=20
          name =3D 0xc057b8d5 "_xmit_TUNNEL6"}}}}, uc =3D {list =3D =
{next =3D 0xcede7120, prev =3D 0xcede7120}, count =3D 0}, mc =3D {list =3D=
 {next =3D 0xcede712c, prev =3D 0xcede712c}, count =3D 0},=20
  uc_promisc =3D 0, promiscuity =3D 0, allmulti =3D 0, atalk_ptr =3D =
0x0, ip_ptr =3D 0xceeb5800, dn_ptr =3D 0x0, ip6_ptr =3D 0xceeb5e00, =
ec_ptr =3D 0x0, ax25_ptr =3D 0x0, ieee80211_ptr =3D 0x0,=20
  last_rx =3D 0, dev_addr =3D 0xced57588 " \001\a8\0200\020\005PT", =
dev_addrs =3D {list =3D {next =3D 0xced57580, prev =3D 0xced57580}, =
count =3D 1},=20
  broadcast =3D " \001\a8\0200\000\001\000\000\000\000\000\000\020", =
'\0' <repeats 16 times>, rx_queue =3D {dev =3D 0xcede7000, qdisc =3D =
0xc05e16cc, state =3D 0, qdisc_sleeping =3D 0xc05e16cc,=20
    _xmit_lock =3D {{rlock =3D {raw_lock =3D {slock =3D 1}, magic =3D =
3735899821, owner_cpu =3D 4294967295, owner =3D 0xffffffff, dep_map =3D =
{key =3D 0xc0b97bb4, class_cache =3D 0x0,=20
            name =3D 0xc057b8d5 "_xmit_TUNNEL6"}}, {__padding =3D =
"\001\000\000\000?N??????????", dep_map =3D {key =3D 0xc0b97bb4, =
class_cache =3D 0x0, name =3D 0xc057b8d5 "_xmit_TUNNEL6"}}}},=20
    xmit_lock_owner =3D -1, trans_start =3D 0, tx_bytes =3D 0, =
tx_packets =3D 0, tx_dropped =3D 0}, _tx =3D 0xced57dc0, num_tx_queues =3D=
 1, real_num_tx_queues =3D 1, qdisc =3D 0xc05e176c,=20
  tx_queue_len =3D 0, tx_global_lock =3D {{rlock =3D {raw_lock =3D =
{slock =3D 1}, magic =3D 3735899821, owner_cpu =3D 4294967295, owner =3D =
0xffffffff, dep_map =3D {key =3D 0xc0b978dc, class_cache =3D 0x0,=20
          name =3D 0xc057b3df "&(&dev->tx_global_lock)->rlock"}}, =
{__padding =3D "\001\000\000\000?N??????????", dep_map =3D {key =3D =
0xc0b978dc, class_cache =3D 0x0,=20
          name =3D 0xc057b3df "&(&dev->tx_global_lock)->rlock"}}}}, =
trans_start =3D 0, watchdog_timeo =3D 0, watchdog_timer =3D {entry =3D =
{next =3D 0x0, prev =3D 0x0}, expires =3D 0,=20
    base =3D 0xc06609c0, function =3D 0xc039eb7f <dev_watchdog>, data =3D =
3470684160, slack =3D -1, start_site =3D 0x0, start_comm =3D '\0' =
<repeats 15 times>, start_pid =3D -1, lockdep_map =3D {
      key =3D 0xc0b98144, class_cache =3D 0x0, name =3D 0xc057ca77 =
"&dev->watchdog_timer"}}, refcnt =3D {counter =3D 13}, todo_list =3D =
{next =3D 0x0, prev =3D 0x0}, index_hlist =3D {next =3D 0x0,=20
    pprev =3D 0xcf95fc1c}, link_watch_list =3D {next =3D 0xcede7260, =
prev =3D 0xcede7260}, reg_state =3D NETREG_REGISTERED, rtnl_link_state =3D=
 RTNL_LINK_INITIALIZED,=20
  destructor =3D 0xc038f1b1 <free_netdev>, ml_priv =3D 0x0, br_port =3D =
0x0, macvlan_port =3D 0x0, garp_port =3D 0x0, dev =3D {parent =3D 0x0, p =
=3D 0xcedfe600, kobj =3D {name =3D 0xcfb24ae0 "ip6tnl1",=20
      entry =3D {next =3D 0xcfbd1a8c, prev =3D 0xcf80e7fc}, parent =3D =
0xcf99edc0, kset =3D 0xcf8142a0, ktype =3D 0xc05d414c, sd =3D =
0xced575c0, kref =3D {refcount =3D {counter =3D 2}},=20
      state_initialized =3D 1, state_in_sysfs =3D 1, =
state_add_uevent_sent =3D 1, state_remove_uevent_sent =3D 0, =
uevent_suppress =3D 0}, init_name =3D 0x0, type =3D 0x0, mutex =3D =
{count =3D {
        counter =3D 1}, wait_lock =3D {{rlock =3D {raw_lock =3D {slock =3D=
 1}, magic =3D 3735899821, owner_cpu =3D 4294967295, owner =3D =
0xffffffff, dep_map =3D {key =3D 0xc0661d9c, class_cache =3D 0x0,=20
              name =3D 0xc051d978 "&(&lock->wait_lock)->rlock"}}, =
{__padding =3D "\001\000\000\000?N??????????", dep_map =3D {key =3D =
0xc0661d9c, class_cache =3D 0x0,=20
              name =3D 0xc051d978 "&(&lock->wait_lock)->rlock"}}}}, =
wait_list =3D {next =3D 0xcede72d4, prev =3D 0xcede72d4}, owner =3D 0x0, =
name =3D 0x0, magic =3D 0xcede72b4, dep_map =3D {
        key =3D 0xc066e010, class_cache =3D 0x0, name =3D 0xc05493c7 =
"&__lockdep_no_validate__"}}, bus =3D 0x0, driver =3D 0x0, platform_data =
=3D 0xcede7000, power =3D {power_state =3D {event =3D 0},=20
      can_wakeup =3D 0, should_wakeup =3D 0, async_suspend =3D 0, status =
=3D DPM_INVALID}, dma_mask =3D 0x0, coherent_dma_mask =3D 0, dma_parms =3D=
 0x0, dma_pools =3D {next =3D 0xcede731c,=20
      prev =3D 0xcede731c}, dma_mem =3D 0x0, archdata =3D {acpi_handle =3D=
 0x0}, devt =3D 0, devres_lock =3D {{rlock =3D {raw_lock =3D {slock =3D =
1}, magic =3D 3735899821, owner_cpu =3D 4294967295,=20
          owner =3D 0xffffffff, dep_map =3D {key =3D 0xc0b92e54, =
class_cache =3D 0x0, name =3D 0xc05493e0 =
"&(&dev->devres_lock)->rlock"}}, {__padding =3D =
"\001\000\000\000?N??????????",=20
          dep_map =3D {key =3D 0xc0b92e54, class_cache =3D 0x0, name =3D =
0xc05493e0 "&(&dev->devres_lock)->rlock"}}}}, devres_head =3D {next =3D =
0xcede734c, prev =3D 0xcede734c}, knode_class =3D {
      n_klist =3D 0xcf9aca4c, n_node =3D {next =3D 0xcfbd1b58, prev =3D =
0xcec1d358}, n_ref =3D {refcount =3D {counter =3D 1}}}, class =3D =
0xc05e1008, groups =3D 0xcede7370, release =3D 0},=20
  sysfs_groups =3D {0xc05e1044, 0x0, 0x0, 0x0}, rtnl_link_ops =3D 0x0, =
vlan_features =3D 0, gso_max_size =3D 65536, ethtool_ntuple_list =3D =
{list =3D {next =3D 0xcede738c, prev =3D 0xcede738c},=20
    count =3D 0}}

I would highlight the ifindex and the iflink values! (ifindex =3D 7, =
iflink =3D 4)

2) Next, we duped out the same for the tunnels, which was created by ip =
-6 tunnel add. We found the following:

Breakpoint 4, 0xc0399069 in rtnl_fill_ifinfo (skb=3D0xced2d300, =
dev=3D0xceeb4800, type=3D16, pid=3D568, seq=3D1318435116, change=3D0, =
flags=3D2)
    at =
/mnt/hgfs/svnOnMyMac/SZTAKI/ITSSv6/trunk/kernel/linux-2.6.35.14/net/core/r=
tnetlink.c:1014
1014			if (tb[IFLA_ADDRESS] &&
(gdb) p *dev
$15 =3D {name =3D "ip6test1\000\000\000\000\000\000\000", pm_qos_req =3D =
0x0, name_hlist =3D {next =3D 0x0, pprev =3D 0xcf95f974}, ifalias =3D =
0x0, mem_end =3D 0, mem_start =3D 0, base_addr =3D 0,=20
  irq =3D 0, if_port =3D 0 '\0', dma =3D 0 '\0', state =3D 3, dev_list =3D=
 {next =3D 0xceeb6838, prev =3D 0xcec1d038}, napi_list =3D {next =3D =
0xceeb4840, prev =3D 0xceeb4840}, unreg_list =3D {
    next =3D 0xceeb4848, prev =3D 0xceeb4848}, features =3D 8192, =
ifindex =3D 7, iflink =3D 7, stats =3D {rx_packets =3D 0, tx_packets =3D =
0, rx_bytes =3D 0, tx_bytes =3D 0, rx_errors =3D 0, tx_errors =3D 0,=20
    rx_dropped =3D 0, tx_dropped =3D 0, multicast =3D 0, collisions =3D =
0, rx_length_errors =3D 0, rx_over_errors =3D 0, rx_crc_errors =3D 0, =
rx_frame_errors =3D 0, rx_fifo_errors =3D 0,=20
    rx_missed_errors =3D 0, tx_aborted_errors =3D 0, tx_carrier_errors =3D=
 0, tx_fifo_errors =3D 0, tx_heartbeat_errors =3D 0, tx_window_errors =3D =
0, rx_compressed =3D 0, tx_compressed =3D 0},=20
  netdev_ops =3D 0xc0461c78, ethtool_ops =3D 0x0, header_ops =3D 0x0, =
flags =3D 145, gflags =3D 0, priv_flags =3D 1024, padded =3D 0, =
operstate =3D 0 '\0', link_mode =3D 0 '\0', mtu =3D 1460, type =3D 769,=20=

  hard_header_len =3D 54, needed_headroom =3D 0, needed_tailroom =3D 0, =
master =3D 0x0, perm_addr =3D '\0' <repeats 31 times>, addr_len =3D 16 =
'\020', dev_id =3D 0, addr_list_lock =3D {{rlock =3D {
        raw_lock =3D {slock =3D 1}, magic =3D 3735899821, owner_cpu =3D =
4294967295, owner =3D 0xffffffff, dep_map =3D {key =3D 0xc0b979dc, =
class_cache =3D 0xc072c2a0,=20
          name =3D 0xc057b8d5 "_xmit_TUNNEL6"}}, {__padding =3D =
"\001\000\000\000?N??????????", dep_map =3D {key =3D 0xc0b979dc, =
class_cache =3D 0xc072c2a0,=20
          name =3D 0xc057b8d5 "_xmit_TUNNEL6"}}}}, uc =3D {list =3D =
{next =3D 0xceeb4920, prev =3D 0xceeb4920}, count =3D 0}, mc =3D {list =3D=
 {next =3D 0xceeb492c, prev =3D 0xceeb492c}, count =3D 0},=20
  uc_promisc =3D 0, promiscuity =3D 0, allmulti =3D 0, atalk_ptr =3D =
0x0, ip_ptr =3D 0xced77400, dn_ptr =3D 0x0, ip6_ptr =3D 0xced77e00, =
ec_ptr =3D 0x0, ax25_ptr =3D 0x0, ieee80211_ptr =3D 0x0,=20
  last_rx =3D 0, dev_addr =3D 0xced58c88 " \001\a8\0200\020\004PT", =
dev_addrs =3D {list =3D {next =3D 0xced58c80, prev =3D 0xced58c80}, =
count =3D 1},=20
  broadcast =3D " \001\a8\0200\000\001\000\000\000\000\000\000\020", =
'\0' <repeats 16 times>, rx_queue =3D {dev =3D 0xceeb4800, qdisc =3D =
0xc05e16cc, state =3D 0, qdisc_sleeping =3D 0xc05e16cc,=20
    _xmit_lock =3D {{rlock =3D {raw_lock =3D {slock =3D 1}, magic =3D =
3735899821, owner_cpu =3D 4294967295, owner =3D 0xffffffff, dep_map =3D =
{key =3D 0xc0b97bb4, class_cache =3D 0x0,=20
            name =3D 0xc057b8d5 "_xmit_TUNNEL6"}}, {__padding =3D =
"\001\000\000\000?N??????????", dep_map =3D {key =3D 0xc0b97bb4, =
class_cache =3D 0x0, name =3D 0xc057b8d5 "_xmit_TUNNEL6"}}}},=20
    xmit_lock_owner =3D -1, trans_start =3D 0, tx_bytes =3D 0, =
tx_packets =3D 0, tx_dropped =3D 0}, _tx =3D 0xced58c40, num_tx_queues =3D=
 1, real_num_tx_queues =3D 1, qdisc =3D 0xc05e176c,=20
  tx_queue_len =3D 0, tx_global_lock =3D {{rlock =3D {raw_lock =3D =
{slock =3D 1}, magic =3D 3735899821, owner_cpu =3D 4294967295, owner =3D =
0xffffffff, dep_map =3D {key =3D 0xc0b978dc, class_cache =3D 0x0,=20
          name =3D 0xc057b3df "&(&dev->tx_global_lock)->rlock"}}, =
{__padding =3D "\001\000\000\000?N??????????", dep_map =3D {key =3D =
0xc0b978dc, class_cache =3D 0x0,=20
          name =3D 0xc057b3df "&(&dev->tx_global_lock)->rlock"}}}}, =
trans_start =3D 0, watchdog_timeo =3D 0, watchdog_timer =3D {entry =3D =
{next =3D 0x0, prev =3D 0x0}, expires =3D 0,=20
    base =3D 0xc06609c0, function =3D 0xc039eb7f <dev_watchdog>, data =3D =
3471525888, slack =3D -1, start_site =3D 0x0, start_comm =3D '\0' =
<repeats 15 times>, start_pid =3D -1, lockdep_map =3D {
      key =3D 0xc0b98144, class_cache =3D 0x0, name =3D 0xc057ca77 =
"&dev->watchdog_timer"}}, refcnt =3D {counter =3D 11}, todo_list =3D =
{next =3D 0x0, prev =3D 0x0}, index_hlist =3D {next =3D 0x0,=20
    pprev =3D 0xcf95fc1c}, link_watch_list =3D {next =3D 0xceeb4a60, =
prev =3D 0xceeb4a60}, reg_state =3D NETREG_REGISTERED, rtnl_link_state =3D=
 RTNL_LINK_INITIALIZED,=20
  destructor =3D 0xc038f1b1 <free_netdev>, ml_priv =3D 0x0, br_port =3D =
0x0, macvlan_port =3D 0x0, garp_port =3D 0x0, dev =3D {parent =3D 0x0, p =
=3D 0xceea7380, kobj =3D {name =3D 0xcfb54780 "ip6test1",=20
      entry =3D {next =3D 0xceeb6a8c, prev =3D 0xcf80d7fc}, parent =3D =
0xcf99fdc0, kset =3D 0xcf8142a0, ktype =3D 0xc05d414c, sd =3D =
0xced58780, kref =3D {refcount =3D {counter =3D 2}},=20
      state_initialized =3D 1, state_in_sysfs =3D 1, =
state_add_uevent_sent =3D 1, state_remove_uevent_sent =3D 0, =
uevent_suppress =3D 0}, init_name =3D 0x0, type =3D 0x0, mutex =3D =
{count =3D {
        counter =3D 1}, wait_lock =3D {{rlock =3D {raw_lock =3D {slock =3D=
 1}, magic =3D 3735899821, owner_cpu =3D 4294967295, owner =3D =
0xffffffff, dep_map =3D {key =3D 0xc0661d9c, class_cache =3D 0x0,=20
              name =3D 0xc051d978 "&(&lock->wait_lock)->rlock"}}, =
{__padding =3D "\001\000\000\000?N??????????", dep_map =3D {key =3D =
0xc0661d9c, class_cache =3D 0x0,=20
              name =3D 0xc051d978 "&(&lock->wait_lock)->rlock"}}}}, =
wait_list =3D {next =3D 0xceeb4ad4, prev =3D 0xceeb4ad4}, owner =3D 0x0, =
name =3D 0x0, magic =3D 0xceeb4ab4, dep_map =3D {
        key =3D 0xc066e010, class_cache =3D 0x0, name =3D 0xc05493c7 =
"&__lockdep_no_validate__"}}, bus =3D 0x0, driver =3D 0x0, platform_data =
=3D 0xceeb4800, power =3D {power_state =3D {event =3D 0},=20
      can_wakeup =3D 0, should_wakeup =3D 0, async_suspend =3D 0, status =
=3D DPM_INVALID}, dma_mask =3D 0x0, coherent_dma_mask =3D 0, dma_parms =3D=
 0x0, dma_pools =3D {next =3D 0xceeb4b1c,=20
      prev =3D 0xceeb4b1c}, dma_mem =3D 0x0, archdata =3D {acpi_handle =3D=
 0x0}, devt =3D 0, devres_lock =3D {{rlock =3D {raw_lock =3D {slock =3D =
1}, magic =3D 3735899821, owner_cpu =3D 4294967295,=20
          owner =3D 0xffffffff, dep_map =3D {key =3D 0xc0b92e54, =
class_cache =3D 0x0, name =3D 0xc05493e0 =
"&(&dev->devres_lock)->rlock"}}, {__padding =3D =
"\001\000\000\000?N??????????",=20
          dep_map =3D {key =3D 0xc0b92e54, class_cache =3D 0x0, name =3D =
0xc05493e0 "&(&dev->devres_lock)->rlock"}}}}, devres_head =3D {next =3D =
0xceeb4b4c, prev =3D 0xceeb4b4c}, knode_class =3D {
      n_klist =3D 0xcf9ada4c, n_node =3D {next =3D 0xceeb6b58, prev =3D =
0xcec1d358}, n_ref =3D {refcount =3D {counter =3D 1}}}, class =3D =
0xc05e1008, groups =3D 0xceeb4b70, release =3D 0},=20
  sysfs_groups =3D {0xc05e1044, 0x0, 0x0, 0x0}, rtnl_link_ops =3D 0x0, =
vlan_features =3D 0, gso_max_size =3D 65536, ethtool_ntuple_list =3D =
{list =3D {next =3D 0xceeb4b8c, prev =3D 0xceeb4b8c},=20
    count =3D 0}}

Highlight again: ifindex =3D 7 iflink =3D 7. I would like to repeat, =
that it is the working version, and the mip6d version is the wrong from =
the usage's point-of-view.

3) What we see from userspace? The ip -6 addr ls is a good help.
If we just added the interface we see:

7: ip6test1: <POINTOPOINT,NOARP,UP,LOWER_UP> mtu 1460
    inet6 2001:738:1030:1::3/128 scope global
       valid_lft forever preferred_lft forever
    inet6 fe80::5054:ff:fe12:3459/64 scope link
       valid_lft forever preferred_lft forever

If it has been changed (by mip6d or with the ip -6 tunnel change =
command):

7: ip6tnl1@eth1: <POINTOPOINT,NOARP,UP,LOWER_UP> mtu 1460=20
    inet6 2001:738:1030:1::3/128 scope global home nodad=20
       valid_lft forever preferred_lft forever
    inet6 fe80::5054:ff:fe12:3459/64 scope link=20
       valid_lft forever preferred_lft forever

The '@' signs that the ifindex and the iflink values are different.

4) One more addition (maybe it helps): The link-local address all of the =
tunnels are the same, and equals the LL address of eth0. It is quite =
interesting, because any of the tunnels linked to eth0. (The tunnels are =
linked to eth1 and eth2).

--- --- --- --- --

We would like to fix this issue very much, but we don't know what was =
the concept of the existing code. We're sure that the exisiting =
mechanism is wrong, when the change method procedures a totally =
different result that the add. We would appreciate any help or comment!


Thank you very much!



Regards,
Andr=E1s




--Apple-Mail=_02DAE481-C9B7-407C-9EDA-EEC3A2C8F3BB
Content-Disposition: attachment;
	filename=test-ip6-tnls.sh
Content-Type: application/octet-stream;
	name="test-ip6-tnls.sh"
Content-Transfer-Encoding: 7bit

#!/bin/sh

###
# You should edit these lines

COA_PREFIXLEN=64
HA_ADDR=2001:738:1030:1::1000
HOA_ADDR=2001:738:1030:1::3
HOA_PREFIXLEN=128
MNP_PREFIX=2001:738:1030:2003::
MNP_PREFIXLEN=64

TEST1_PEER=2a01:270:d003::1
TEST2_PEER=2a01:1450:4001:c01::93

###
# You may edit these lines
IF1=eth1
IF2=eth2
TNL1=ip6test1
TNL2=ip6test2
IF1_RR_LLADDR=fe80::20c:29ff:fe3b:4d16
IF2_RR_LLADDR=fe80::20c:29ff:fe3b:4d20

###
# Please do not edit these lines

case "$1" in
"init")
	echo "Initializing"

	IF1_ADDR=`ip -6 a show dev $IF1 scope global | sed -ne 's/^[ ]*inet6 \([0-f0-9:/]\+\) scope global .*$/\1/p'`
	IF2_ADDR=`ip -6 a show dev $IF2 scope global | sed -ne 's/^[ ]*inet6 \([0-f0-9:/]\+\) scope global .*$/\1/p'`
	PREFIXLEN=`expr \( 128 - $COA_PREFIXLEN \) / 8 / 2`
	IF1_PREFIX="`ip -6 a show dev $IF1 scope global | sed -ne "s/^[ ]*inet6 \(\([a-f0-9]\+:\)\{$PREFIXLEN\}\)[a-f0-9:/]\+ scope global .*\$/\1/p"`:"
	IF2_PREFIX="`ip -6 a show dev $IF2 scope global | sed -ne "s/^[ ]*inet6 \(\([a-f0-9]\+:\)\{$PREFIXLEN\}\)[a-f0-9:/]\+ scope global .*\$/\1/p"`:"
	if [ "x$IF1_RR_LLADDR" = "x" ]; then
		IF1_RR_LLADDR=`ip -6 neigh ls | sed -ne "s/^\([a-f0-9:]\+\) dev $IF1 lladdr .*\$/\1/p"`
	fi
	if [ "x$IF2_RR_LLADDR" = "x" ]; then
		IF2_RR_LLADDR=`ip -6 neigh ls | sed -ne "s/^\([a-f0-9:]\+\) dev $IF2 lladdr .*\$/\1/p"`
	fi

	echo "$IF1 address: $IF1_ADDR"
	echo "$IF2 address: $IF2_ADDR"
	echo "$IF1 prefix: $IF1_PREFIX"
	echo "$IF2 prefix: $IF2_PREFIX"
	echo "$IF1 router's LL address: $IF1_RR_LLADDR"
	echo "$IF2 router's LL address: $IF2_RR_LLADDR"

	ip -6 r add default via $IF1_RR_LLADDR dev $IF1
	ip -6 r add default via $IF2_RR_LLADDR dev $IF2

	if [ "x`ip -6 tunnel ls | grep $TNL1`" != "x" ]; then
		ip -6 tunnel del $TNL1
	fi
	if [ "x`ip -6 tunnel ls | grep $TNL1`" != "x" ]; then
		ip -6 tunnel del $TNL2
	fi
	ip -6 tunnel add $TNL1 mode ip6ip6 remote $HA_ADDR local $IF1_ADDR dev $IF1 encaplimit none hoplimit 64 tclass 0x00 flowlabel 0x00000000
	ip -6 tunnel add $TNL2 mode ip6ip6 remote $HA_ADDR local $IF2_ADDR dev $IF2 encaplimit none hoplimit 64 tclass 0x00 flowlabel 0x00000000
	ip l set $TNL1 up
	ip l set $TNL2 up

	ip -6 a add $HOA_ADDR/$HOA_PREFIXLEN dev $TNL1
	ip -6 a add $HOA_ADDR/$HOA_PREFIXLEN dev $TNL2

	# Note: the $MNP_PREFIX/$MNP_PREFIXLEN rules for forwarded packets from MNN
	ip -6 rule add from all to $MNP_PREFIX/$MNP_PREFIXLEN lookup main pref 1000
	ip -6 rule add from $HOA_ADDR fwmark 0x64 lookup 100 pref 1001
	ip -6 rule add from $HOA_ADDR fwmark 0xc8 lookup 200 pref 1001
	ip -6 rule add from $HOA_ADDR lookup 100 pref 1002
	ip -6 rule add from fe80::/64 lookup main pref 1003
	ip -6 rule add from 2001:738:1030:1004::/64 lookup main pref 1003
	ip -6 rule add from 2001:738:1030:1005::/64 lookup main pref 1003
	ip -6 rule add from $HOA_ADDR blackhole pref 1004
	ip -6 rule add from $MNP_PREFIX/$MNP_PREFIXLEN fwmark 0x64 lookup 100 pref 1006
	ip -6 rule add from $MNP_PREFIX/$MNP_PREFIXLEN fwmark 0xc8 lookup 200 pref 1006
	ip -6 rule add from $MNP_PREFIX/$MNP_PREFIXLEN lookup 100 pref 1007

	ip -6 r add default dev $TNL1 table 100
	ip -6 r add default from $MNP_PREFIX/$MNP_PREFIXLEN dev $TNL1 table 100

	ip -6 r add default dev $TNL2 table 200
	ip -6 r add default from $MNP_PREFIX/$MNP_PREFIXLEN dev $TNL2 table 200

	ip6tables -t mangle -A OUTPUT -d $TEST1_PEER -j MARK --set-xmark 0x64/0xffffffff 
	ip6tables -t mangle -A OUTPUT -d $TEST2_PEER -j MARK --set-xmark 0xc8/0xffffffff 

	;;
"test1")
	echo "Test1 with $TEST1_PEER"
	echo "It should marked with 100"
	echo "It should sent via $TNL1 via $IF1"

	ping -I $HOA_ADDR $TEST1_PEER
	;;
"test2")
	echo "Test2 with $TEST2_PEER"
	echo "It should marked with 200"
	echo "It should sent via $TNL2 via $IF2"
	
	ping -I $HOA_ADDR $TEST2_PEER
	;;
*)
	echo "Usage: $0 [init|test1|test2]"
	exit 1
	;;
esac




--Apple-Mail=_02DAE481-C9B7-407C-9EDA-EEC3A2C8F3BB
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=iso-8859-1




Andr=E1s Tak=E1cs

MTA SZTAKI
Computer and Automation Research Institute
Hungarian Academy of Sciences

Email: andras.takacs@sztaki.hu
Office: +36-1-279-6288
Mobile: +36-70-282-5316


--Apple-Mail=_02DAE481-C9B7-407C-9EDA-EEC3A2C8F3BB--
