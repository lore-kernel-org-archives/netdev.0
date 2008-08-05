From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: thousands of classes, e1000 TX unit hang
Date: Tue, 5 Aug 2008 13:05:40 +0300
Message-ID: <200808051305.41064.denys@visp.net.lb>
References: <200808051047.15605.denys@visp.net.lb> <200808051106.53841.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_1XCmITmZkvQXTMU"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.globalproof.net ([194.146.153.25]:48329 "EHLO
	relay2.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755756AbYHEKG1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Aug 2008 06:06:27 -0400
Received: from [195.69.208.252] (unknown [195.69.208.252])
	by relay2.globalproof.net (Postfix) with ESMTP id B04521304CC
	for <netdev@vger.kernel.org>; Tue,  5 Aug 2008 13:06:23 +0300 (EEST)
In-Reply-To: <200808051106.53841.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Boundary-00=_1XCmITmZkvQXTMU
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

I found, that packetloss happening when i am deleting/adding classes.
I attach result of oprofile as file.
																																																																						 

On Tuesday 05 August 2008, Denys Fedoryshchenko wrote:
> A little bit more info:
>
> On oprofile i run on another machine (which doesn't suffer much, but i can
> notice also drops on eth0 after adding around 100 interfaces). On first
> machine clocksources is TSC, on machine where i read stats acpi_pm.
>
> CPU: P4 / Xeon with 2 hyper-threads, speed 3200.53 MHz (estimated)
> Counted GLOBAL_POWER_EVENTS events (time during which processor is not
> stopped) with a unit mask of 0x01 (mandatory) count 100000
> GLOBAL_POWER_E...|
>   samples|      %|
> ------------------
>    973464 75.7644 vmlinux
>     97703  7.6042 libc-2.6.1.so
>     36166  2.8148 cls_fw
>     18290  1.4235 nf_conntrack
>     17946  1.3967 busybox
>         GLOBAL_POWER_E...|
>
> PU: P4 / Xeon with 2 hyper-threads, speed 3200.53 MHz (estimated)
> Counted GLOBAL_POWER_EVENTS events (time during which processor is not
> stopped) with a unit mask of 0x01 (mandatory) count 100000
> samples  %        symbol name
> 245545   23.1963  acpi_pm_read
> 143863   13.5905  __copy_to_user_ll
> 121269   11.4561  ioread16
> 58609     5.5367  gen_kill_estimator
> 40153     3.7932  ioread32
> 33923     3.2047  ioread8
> 16491     1.5579  arch_task_cache_init
> 16067     1.5178  sysenter_past_esp
> 11604     1.0962  find_get_page
> 10631     1.0043  est_timer
> 9038      0.8538  get_page_from_freelist
> 8681      0.8201  sk_run_filter
> 8077      0.7630  irq_entries_start
> 7711      0.7284  schedule
> 6451      0.6094  copy_to_user
>
> On Tuesday 05 August 2008, Denys Fedoryshchenko wrote:
> > I did script, that looks something like this (to simulate SFQ by flow
> > classifier):
> >
> > $2 (is ppp interface)
> > echo "qdisc del dev $2 root ">>${TEMP}
> > echo "qdisc add dev $2 root handle 1: htb ">>${TEMP}
> >  echo "filter add dev $2 protocol ip pref 16 parent 1: u32 \
> > 	match ip dst 0.0.0.0/0 police rate 8kbit burst 2048kb \
> > 	peakrate 1024Kbit mtu 10000 \
> > 	conform-exceed continue/ok">>${TEMP}
> >
> > echo "filter add dev $2 protocol ip pref 32 parent 1: handle 1 \
> > 	flow hash keys nfct divisor 128 baseclass 1:2">>${TEMP}
> >
> > echo "class add dev $2 parent 1: classid 1:1 htb \
> > 	rate ${rate}bit ceil ${rate}Kbit quantum 1514">>${TEMP}
> >
> > #Cycle to add 128 classes
> > maxslot=130
> > for slot in `seq 2 $maxslot`; do
> > echo "class add dev $2 parent 1:1 classid 1:$slot htb \
> > 	rate 8Kbit ceil 256Kbit quantum 1514">>${TEMP}
> > echo "qdisc add dev $2 handle $slot: parent 1:$slot bfifo limit
> > 3000">>${TEMP} done
> >
> > After adding around 400-450 interfaces (ppp) server start to "crack".
> > Sure there is packetloss to eth0 (but there is no filters or shapers on
> > it). Even deleting all classes becomes a challenge. After deleting all
> > root handles on ppp interfaces - it becomes ok.
> >
> >
> > Traffic over host is 15-20Mbit/s at that moment, it is 1 CPU Xeon 3.0 Ghz
> > on server motherboard SE7520 with 1GB ram available (at moment of testing
> > more than 512Mb was free).
> >
> > Kernel is 2.6.26.1-vanilla
> > Anything else i need to add to info?
> >
> > Error message appearing in dmesg:
> > [149650.006939] e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang
> > [149650.006943]   Tx Queue             <0>
> > [149650.006944]   TDH                  <a3>
> > [149650.006945]   TDT                  <a3>
> > [149650.006947]   next_to_use          <a3>
> > [149650.006948]   next_to_clean        <f8>
> > [149650.006949] buffer_info[next_to_clean]
> > [149650.006951]   time_stamp           <8e69a7c>
> > [149650.006952]   next_to_watch        <f8>
> > [149650.006953]   jiffies              <8e6a111>
> > [149650.006954]   next_to_watch.status <1>
> > [149655.964100] e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang
> > [149655.964104]   Tx Queue             <0>
> > [149655.964105]   TDH                  <6c>
> > [149655.964107]   TDT                  <6c>
> > [149655.964108]   next_to_use          <6c>
> > [149655.964109]   next_to_clean        <c1>
> > [149655.964111] buffer_info[next_to_clean]
> > [149655.964112]   time_stamp           <8e6b198>
> > [149655.964113]   next_to_watch        <c1>
> > [149655.964115]   jiffies              <8e6b853>
> > [149655.964116]   next_to_watch.status <1>
> > [149666.765110] e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang
> > [149666.765110]   Tx Queue             <0>
> > [149666.765110]   TDH                  <28>
> > [149666.765110]   TDT                  <28>
> > [149666.765110]   next_to_use          <28>
> > [149666.765110]   next_to_clean        <7e>
> > [149666.765110] buffer_info[next_to_clean]
> > [149666.765110]   time_stamp           <8e6db6a>
> > [149666.765110]   next_to_watch        <7e>
> > [149666.765110]   jiffies              <8e6e27f>
> > [149666.765110]   next_to_watch.status <1>
> > [149668.629051] e1000: eth1: e1000_clean_tx_irq: Detected Tx Unit Hang
> > [149668.629056]   Tx Queue             <0>
> > [149668.629058]   TDH                  <1b>
> > [149668.629060]   TDT                  <1b>
> > [149668.629062]   next_to_use          <1b>
> > [149668.629064]   next_to_clean        <f1>
> > [149668.629066] buffer_info[next_to_clean]
> > [149668.629068]   time_stamp           <8e6e4c3>
> > [149668.629070]   next_to_watch        <f1>
> > [149668.629072]   jiffies              <8e6e9c7>
> > [149668.629074]   next_to_watch.status <1>
> > [149676.606031] e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang
> > [149676.606035]   Tx Queue             <0>
> > [149676.606037]   TDH                  <9b>
> > [149676.606038]   TDT                  <9b>
> > [149676.606039]   next_to_use          <9b>
> > [149676.606040]   next_to_clean        <f0>
> > [149676.606042] buffer_info[next_to_clean]
> > [149676.606043]   time_stamp           <8e7024c>
> > [149676.606044]   next_to_watch        <f0>
> > [149676.606046]   jiffies              <8e708eb>
> > [149676.606047]   next_to_watch.status <1>
> > [149680.151750] e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang
> > [149680.151750]   Tx Queue             <0>
> > [149680.151750]   TDH                  <84>
> > [149680.151750]   TDT                  <84>
> > [149680.151750]   next_to_use          <84>
> > [149680.151750]   next_to_clean        <d9>
> > [149680.151750] buffer_info[next_to_clean]
> > [149680.151750]   time_stamp           <8e7100d>
> > [149680.151750]   next_to_watch        <d9>
> > [149680.151750]   jiffies              <8e716c3>
> > [149680.151750]   next_to_watch.status <1>
> > [149680.153751] e1000: eth1: e1000_clean_tx_irq: Detected Tx Unit Hang
> > [149680.153751]   Tx Queue             <0>
> > [149680.153751]   TDH                  <aa>
> > [149680.153751]   TDT                  <d2>
> > [149680.153751]   next_to_use          <d2>
> > [149680.153751]   next_to_clean        <2d>
> > [149680.153751] buffer_info[next_to_clean]
> > [149680.153751]   time_stamp           <8e710db>
> > [149680.153751]   next_to_watch        <2d>
> > [149680.153751]   jiffies              <8e716c5>
> > [149680.153751]   next_to_watch.status <1>
> > [149702.565549] e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang
> > [149702.565549]   Tx Queue             <0>
> > [149702.565549]   TDH                  <3c>
> > [149702.565549]   TDT                  <3c>
> > [149702.565549]   next_to_use          <3c>
> > [149702.565549]   next_to_clean        <91>
> > [149702.565549] buffer_info[next_to_clean]
> > [149702.565549]   time_stamp           <8e7676e>
> > [149702.565549]   next_to_watch        <91>
> > [149702.565549]   jiffies              <8e76e48>
> > [149702.565549]   next_to_watch.status <1>
> > [149708.020581] e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang
> > [149708.020581]   Tx Queue             <0>
> > [149708.020581]   TDH                  <4c>
> > [149708.020581]   TDT                  <4c>
> > [149708.020581]   next_to_use          <4c>
> > [149708.020581]   next_to_clean        <a1>
> > [149708.020581] buffer_info[next_to_clean]
> > [149708.020581]   time_stamp           <8e77cc3>
> > [149708.020581]   next_to_watch        <a1>
> > [149708.020581]   jiffies              <8e78394>
> > [149708.020581]   next_to_watch.status <1>
> > [149713.864829] e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang
> > [149713.864833]   Tx Queue             <0>
> > [149713.864835]   TDH                  <b0>
> > [149713.864836]   TDT                  <b0>
> > [149713.864837]   next_to_use          <b0>
> > [149713.864839]   next_to_clean        <5>
> > [149713.864840] buffer_info[next_to_clean]
> > [149713.864841]   time_stamp           <8e7937b>
> > [149713.864842]   next_to_watch        <5>
> > [149713.864844]   jiffies              <8e79a64>
> > [149713.864845]   next_to_watch.status <1>
> > [149759.710721] e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang
> > [149759.710726]   Tx Queue             <0>
> > [149759.710729]   TDH                  <88>
> > [149759.710730]   TDT                  <88>
> > [149759.710732]   next_to_use          <88>
> > [149759.710734]   next_to_clean        <dd>
> > [149759.710736] buffer_info[next_to_clean]
> > [149759.710738]   time_stamp           <8e8465c>
> > [149759.710740]   next_to_watch        <dd>
> > [149759.710742]   jiffies              <8e84d6f>
> > [149759.710744]   next_to_watch.status <1>
> > [149759.712712] e1000: eth1: e1000_clean_tx_irq: Detected Tx Unit Hang
> > [149759.712715]   Tx Queue             <0>
> > [149759.712717]   TDH                  <84>
> > [149759.712719]   TDT                  <90>
> > [149759.712721]   next_to_use          <90>
> > [149759.712723]   next_to_clean        <e5>
> > [149759.712725] buffer_info[next_to_clean]
> > [149759.712726]   time_stamp           <8e84782>
> > [149759.712728]   next_to_watch        <e5>
> > [149759.712730]   jiffies              <8e84d71>
> > [149759.712732]   next_to_watch.status <1>
> > [149768.334753] e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang
> > [149768.334757]   Tx Queue             <0>
> > [149768.334758]   TDH                  <92>
> > [149768.334760]   TDT                  <92>
> > [149768.334761]   next_to_use          <92>
> > [149768.334762]   next_to_clean        <e7>
> > [149768.334764] buffer_info[next_to_clean]
> > [149768.334765]   time_stamp           <8e86829>
> > [149768.334766]   next_to_watch        <e7>
> > [149768.334767]   jiffies              <8e86f1c>
> > [149768.334769]   next_to_watch.status <1>
> > [149776.537825] e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang
> > [149776.537825]   Tx Queue             <0>
> > [149776.537825]   TDH                  <4e>
> > [149776.537825]   TDT                  <4e>
> > [149776.537825]   next_to_use          <4e>
> > [149776.537825]   next_to_clean        <a3>
> > [149776.537825] buffer_info[next_to_clean]
> > [149776.537825]   time_stamp           <8e8882b>
> > [149776.537825]   next_to_watch        <a3>
> > [149776.537825]   jiffies              <8e88f21>
> > [149776.537825]   next_to_watch.status <1>
> > --
> > To unsubscribe from this list: send the line "unsubscribe netdev" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



--Boundary-00=_1XCmITmZkvQXTMU
Content-Type: text/plain;
  charset="iso-8859-1";
  name="oprofile_result1.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="oprofile_result1.txt"

CPU: P4 / Xeon with 2 hyper-threads, speed 3200.53 MHz (estimated)
Counted GLOBAL_POWER_EVENTS events (time during which processor is not stopped) with a unit mask of 0x01 (mandatory) count 10000
samples  %        symbol name
348827   33.2260  gen_kill_estimator
124818   11.8890  acpi_pm_read
44388     4.2280  ioread16
35074     3.3408  __copy_to_user_ll
33251     3.1672  rtnl_fill_ifinfo
18708     1.7819  ioread32
18350     1.7478  netif_receive_skb
17045     1.6235  copy_to_user
15829     1.5077  __nla_reserve
15261     1.4536  page_fault
14644     1.3948  rtnl_dump_ifinfo
12348     1.1762  __nla_put
11149     1.0619  dev_queue_xmit
11077     1.0551  ioread8
8327      0.7932  sysenter_past_esp
7279      0.6933  est_timer
6631      0.6316  get_page_from_freelist
4863      0.4632  handle_mm_fault
4817      0.4588  csum_partial
4782      0.4555  strlen
4644      0.4423  find_vma
4422      0.4212  nla_put
4406      0.4197  ip_route_input
4200      0.4001  skb_put

Here is details from opannotate

c024dc30 <gen_kill_estimator>: /* gen_kill_estimator total: 266925 23.2740 */
               :c024dc30:       push   %ebp
     1 8.7e-05 :c024dc31:       mov    %esp,%ebp
               :c024dc33:       push   %edi
               :c024dc34:       xor    %edi,%edi
               :c024dc36:       push   %esi
               :c024dc37:       push   %ebx
               :c024dc38:       sub    $0x10,%esp
               :c024dc3b:       mov    %eax,0xffffffe8(%ebp)
               :c024dc3e:       mov    %edx,0xffffffe4(%ebp)
               :c024dc41:       movl   $0xc08630bc,0xfffffff0(%ebp)
               :c024dc48:       mov    0xfffffff0(%ebp),%eax
     1 8.7e-05 :c024dc4b:       cmpl   $0x0,(%eax)
    26  0.0023 :c024dc4e:       je     c024dcb6 <gen_kill_estimator+0x86>
     3 2.6e-04 :c024dc50:       mov    0xc(%eax),%ebx
     3 2.6e-04 :c024dc53:       mov    %edi,%eax
               :c024dc55:       shl    $0x5,%eax
               :c024dc58:       add    $0xc08630c8,%eax
     1 8.7e-05 :c024dc5d:       mov    (%ebx),%esi
     4 3.5e-04 :c024dc5f:       mov    %eax,0xffffffec(%ebp)
               :c024dc62:       jmp    c024dcb1 <gen_kill_estimator+0x81>
   782  0.0682 :c024dc64:       mov    0xffffffe4(%ebp),%eax
   390  0.0340 :c024dc67:       cmp    %eax,0xc(%ebx)
 12239  1.0672 :c024dc6a:       jne    c024dcad <gen_kill_estimator+0x7d>
               :c024dc6c:       mov    0xffffffe8(%ebp),%eax
               :c024dc6f:       cmp    %eax,0x8(%ebx)
               :c024dc72:       jne    c024dcad <gen_kill_estimator+0x7d>
               :c024dc74:       mov    $0xc036d620,%eax
               :c024dc79:       call   c02a7817 <_write_lock_bh>
     3 2.6e-04 :c024dc7e:       mov    $0xc036d620,%eax
               :c024dc83:       movl   $0x0,0x8(%ebx)
               :c024dc8a:       call   c02a78ac <_write_unlock_bh>
               :c024dc8f:       mov    0x4(%ebx),%edx
               :c024dc92:       mov    (%ebx),%eax
               :c024dc94:       mov    %edx,0x4(%eax)
               :c024dc97:       mov    %eax,(%edx)
               :c024dc99:       lea    0x2c(%ebx),%eax
               :c024dc9c:       mov    $0xc024dcc8,%edx
               :c024dca1:       movl   $0x200200,0x4(%ebx)
               :c024dca8:       call   c014279c <call_rcu>
  6905  0.6021 :c024dcad:       mov    %esi,%ebx
  1716  0.1496 :c024dcaf:       mov    (%esi),%esi
232351 20.2593 :c024dcb1:       cmp    0xffffffec(%ebp),%ebx
 12492  1.0892 :c024dcb4:       jne    c024dc64 <gen_kill_estimator+0x34>
     2 1.7e-04 :c024dcb6:       inc    %edi
     5 4.4e-04 :c024dcb7:       addl   $0x20,0xfffffff0(%ebp)
               :c024dcbb:       cmp    $0x6,%edi
               :c024dcbe:       jne    c024dc48 <gen_kill_estimator+0x18>
               :c024dcc0:       add    $0x10,%esp
               :c024dcc3:       pop    %ebx
               :c024dcc4:       pop    %esi
     1 8.7e-05 :c024dcc5:       pop    %edi
																																															               :c024dc94:       mov    %edx,0x4(%eax)
																																																                      :c024dc97:       mov    %eax,(%edx)
																																																		                     :c024dc99:       lea    0x2c(%ebx),%eax
																																																				                    :c024dc9c:       mov    $0xc024dcc8,%edx
																																																						                   :c024dca1:       movl   $0x200200,0x4(%ebx)
																																																								                  :c024dca8:       call   c014279c <call_rcu>
																																																										    6905  0.6021 :c024dcad:       mov    %esi,%ebx
																																																										      1716  0.1496 :c024dcaf:       mov    (%esi),%esi
																																																										      232351 20.2593 :c024dcb1:       cmp    0xffffffec(%ebp),%ebx
																																																										       12492  1.0892 :c024dcb4:       jne    c024dc64 <gen_kill_estimator+0x34>
																																																										            2 1.7e-04 :c024dcb6:       inc    %edi
																																																											         5 4.4e-04 :c024dcb7:       addl   $0x20,0xfffffff0(%ebp)
																																																												                :c024dcbb:       cmp    $0x6,%edi
																																																														               :c024dcbe:       jne    c024dc48 <gen_kill_estimator+0x18>
																																																															                      :c024dcc0:       add    $0x10,%esp
																																																																	                     :c024dcc3:       pop    %ebx
																																																																			                    :c024dcc4:       pop    %esi
																																																																					         1 8.7e-05 :c024dcc5:       pop    %edi
																																																																						 
--Boundary-00=_1XCmITmZkvQXTMU--
