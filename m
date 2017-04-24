From: Benjamin Poirier <bpoirier@suse.com>
Subject: Re: [Intel-wired-lan] [PATCH 1/2] e1000e: Don't return uninitialized
 stats
Date: Mon, 24 Apr 2017 12:01:51 -0700
Message-ID: <20170424190151.cbmbbeyjspoolpho@f1.synalogic.ca>
References: <20170421212012.25950-1-bpoirier@suse.com>
 <71d8032d-5ed1-8242-83e6-16ce65718966@molgen.mpg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
        intel-wired-lan@lists.osuosl.org,
        Stefan Priebe <s.priebe@profihost.ag>
To: Paul Menzel <pmenzel@molgen.mpg.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:45357 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S972730AbdDXTB5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 24 Apr 2017 15:01:57 -0400
Content-Disposition: inline
In-Reply-To: <71d8032d-5ed1-8242-83e6-16ce65718966@molgen.mpg.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2017/04/24 10:23, Paul Menzel wrote:
> Dear Benjamin,
> 
> 
> Thank you for your fix.
> 
> On 04/21/17 23:20, Benjamin Poirier wrote:
> > Some statistics passed to ethtool are garbage because e1000e_get_stats64()
> > doesn't write them, for example: tx_heartbeat_errors. This leaks kernel
> > memory to userspace and confuses users.
> 
> Could you please give specific examples to reproduce the issue? That way
> your fix can also be tested.
> 

Some fields in e1000_get_ethtool_stats()'s net_stats are not initialized
by e1000e_get_stats64(). The structure is allocated on the stack,
therefore, the value of those fields depends on previous stack content;
that in turns depends on kernel version, compiler and previous execution
path. I've tried on 8 machines with different kernel versions and it
reproduced on 3.

root@linux-zxe0:/usr/local/src/linux# git log -n1 --oneline
fc1f8f4f310a net: ipv6: send unsolicited NA if enabled for all interfaces
root@linux-zxe0:/usr/local/src/linux# ethtool -i eth0
driver: e1000e
[...]
root@linux-zxe0:/usr/local/src/linux# ethtool -S eth0
NIC statistics:
     rx_packets: 217
     tx_packets: 153
     rx_bytes: 23091
     tx_bytes: 20533
     rx_broadcast: 0
     tx_broadcast: 6
     rx_multicast: 0
     tx_multicast: 10
     rx_errors: 0
     tx_errors: 0
     tx_dropped: 18446683600612146192
     multicast: 0
     collisions: 0
     rx_length_errors: 0
     rx_over_errors: 70364470214850
     rx_crc_errors: 0
     rx_frame_errors: 0
     rx_no_buffer_count: 0
     rx_missed_errors: 0
     tx_aborted_errors: 0
     tx_carrier_errors: 0
     tx_fifo_errors: 18446744072101618112
     tx_heartbeat_errors: 18446612150964469760
[...]

(gdb) p /x 18446683600612146192
$1 = 0xffffc9000282bc10
(gdb) p /x 18446744072101618112
$2 = 0xffffffffa028e1c0
(gdb) p /x 18446612150964469760
$3 = 0xffff880457a44000
... a bunch of kernel addresses

Inserting a dummy memset is a reliable way to show the issue:

--- a/drivers/net/ethernet/intel/e1000e/ethtool.c
+++ b/drivers/net/ethernet/intel/e1000e/ethtool.c
@@ -2061,6 +2061,8 @@ static void e1000_get_ethtool_stats(struct net_device *netdev,
        int i;
        char *p = NULL;

+       memset(&net_stats, 0xff, sizeof(net_stats));
+
        pm_runtime_get_sync(netdev->dev.parent);

        e1000e_get_stats64(netdev, &net_stats);

root@linux-zxe0:/usr/local/src/linux# ethtool -S eth0
NIC statistics:
     rx_packets: 30
     tx_packets: 29
     rx_bytes: 2924
     tx_bytes: 3012
     rx_broadcast: 0
     tx_broadcast: 6
     rx_multicast: 0
     tx_multicast: 7
     rx_errors: 0
     tx_errors: 0
     tx_dropped: 18446744073709551615
     multicast: 0
     collisions: 0
     rx_length_errors: 0
     rx_over_errors: 18446744073709551615
     rx_crc_errors: 0
     rx_frame_errors: 0
     rx_no_buffer_count: 0
     rx_missed_errors: 0
     tx_aborted_errors: 0
     tx_carrier_errors: 0
     tx_fifo_errors: 18446744073709551615
     tx_heartbeat_errors: 18446744073709551615
[...]

(gdb) p /x 18446744073709551615
$1 = 0xffffffffffffffff
