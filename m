From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next 04/17] drivers/net/intel: use napi_complete_done()
Date: Thu, 12 Nov 2015 21:18:16 -0800
Message-ID: <1447391896.22599.36.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1444945404-30654-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1444945404-30654-5-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:36275 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751183AbbKMFSS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2015 00:18:18 -0500
Received: by pacdm15 with SMTP id dm15so88532274pac.3
        for <netdev@vger.kernel.org>; Thu, 12 Nov 2015 21:18:18 -0800 (PST)
In-Reply-To: <1444945404-30654-5-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-10-15 at 14:43 -0700, Jeff Kirsher wrote:
> From: Jesse Brandeburg <jesse.brandeburg@intel.com>
> 
> As per Eric Dumazet's previous patches:
> (see commit (24d2e4a50737) - tg3: use napi_complete_done())
> 
> Quoting verbatim:
> Using napi_complete_done() instead of napi_complete() allows
> us to use /sys/class/net/ethX/gro_flush_timeout
> 
> GRO layer can aggregate more packets if the flush is delayed a bit,
> without having to set too big coalescing parameters that impact
> latencies.
> </end quote>
> 
> Tested
> configuration: low latency via ethtool -C ethx adaptive-rx off
> 				rx-usecs 10 adaptive-tx off tx-usecs 15
> workload: streaming rx using netperf TCP_MAERTS
> 
> igb:
> MIGRATED TCP MAERTS TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 10.0.0.1 () port 0 AF_INET : demo
> ...
> Interim result:  941.48 10^6bits/s over 1.000 seconds ending at 1440193171.589
> 
> Alignment      Offset         Bytes    Bytes       Recvs   Bytes    Sends
> Local  Remote  Local  Remote  Xfered   Per                 Per
> Recv   Send    Recv   Send             Recv (avg)          Send (avg)
>     8       8      0       0 1176930056  1475.36    797726   16384.00  71905
> 
> MIGRATED TCP MAERTS TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 10.0.0.1 () port 0 AF_INET : demo
> ...
> Interim result:  941.49 10^6bits/s over 0.997 seconds ending at 1440193142.763
> 
> Alignment      Offset         Bytes    Bytes       Recvs   Bytes    Sends
> Local  Remote  Local  Remote  Xfered   Per                 Per
> Recv   Send    Recv   Send             Recv (avg)          Send (avg)
>     8       8      0       0 1175182320  50476.00     23282   16384.00  71816
> 
> i40e:
> Hard to test because the traffic is incoming so fast (24Gb/s) that GRO
> always receives 87kB, even at the highest interrupt rate.
> 
> Other drivers were only compile tested.
> 
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>


Hi guys

I am not sure the ixgbe part is working :

ixgbe_qv_unlock_napi() does :

/* flush any outstanding Rx frames */
if (q_vector->napi.gro_list)
        napi_gro_flush(&q_vector->napi, false);

And it is called before napi_complete_done(napi, work_done);
