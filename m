From: John Stultz <john.stultz@linaro.org>
Subject: Re: [REGRESSION] asix: Lots of asix_rx_fixup() errors and slow transmissions
Date: Fri, 6 May 2016 10:06:13 -0700
Message-ID: <CALAqxLWbKs94QHXHak2OPohzv30Lp6jCfODNgTfV0fT4Be593A@mail.gmail.com>
References: <CALAqxLUj+-yUGTNviHu4+KE9=JTxjZyHBv4pdUob=xndAr8ZmA@mail.gmail.com>
	<57286E15.2080900@mentor.com>
	<CAFGCpxx0f7g7rXyZ-P0EF7QVX7Z0ziK+7VMPKK7pQteBowkw3Q@mail.gmail.com>
	<5728837D.60702@mentor.com>
	<CALAqxLXbMuK3Sj45vbf_r4GYQR=8bGUrhDz9-7+S2pbO_dJZ4A@mail.gmail.com>
	<572B0023.9060505@mentor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Guodong Xu <guodong.xu@linaro.org>,
	lkml <linux-kernel@vger.kernel.org>,
	Mark Craske <Mark_Craske@mentor.com>,
	"David S. Miller" <davem@davemloft.net>,
	YongQin Liu <yongqin.liu@linaro.org>,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	Ivan Vecera <ivecera@redhat.com>,
	"David B. Robins" <linux@davidrobins.net>
To: Dean Jenkins <Dean_Jenkins@mentor.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <572B0023.9060505@mentor.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 5, 2016 at 1:11 AM, Dean Jenkins <Dean_Jenkins@mentor.com> wrote:
> On 05/05/16 00:45, John Stultz wrote:
>>
>> Just as a sample point, I have managed to reproduce exactly this issue
>> on an x86_64 system by simply scp'ing a large file.
>
> Please tell us the x86_64 kernel version number that you used and which
> Linux Distribution it was ? This allows other people a chance to reproduce
> your observations.

Sorry for being a little slow here, had some other issues I had to chase.

On my x86_64 system, its Ubuntu 14.04.4, with a 4.6.0-rc2 kernel.


>> [  417.819276] asix 1-5:1.0 eth1: asix_rx_fixup() Data Header
>> synchronisation was lost, remaining 988
>
> It is interesting that the reported "remaining" value is 988. Is 988 always
> shown ? I mean that do you see any other "remaining" values for the "Data
> Header synchronisation was lost" error message ?

Yep. Its always the same 988 remaining, on either architecture.


>> [  417.823415] asix 1-5:1.0 eth1: asix_rx_fixup() Bad Header Length
>> 0xef830347, offset 4
>
> The gap in the timestamps shows 417.823415 - 417.819276 = 0.004139 = 4ms
> which is a large gap in terms of USB 2.0 high speed communications. This gap
> is expected to be in the 100us range for consecutive URBs. So 4ms is
> strange.
>
> The expectation is that the "Data Header synchronisation was lost" error
> message resets the 32-bit header word synchronisation to the start of the
> next URB buffer. The "Bad Header Length, offset 4" is the expected outcome
> for the next URB because it is unlikely the 32-bit header word is at the
> start of URB buffer due to Ethernet frames spanning across URBs.
>>
>> [  417.827502] asix 1-5:1.0 eth1: asix_rx_fixup() Bad Header Length
>> 0x31e2b348, offset 4
>
> Timestamps show the gap to be 4ms which is strange for USB 2.0 high speed,
> are you sure high speed mode is being used ?
>>

Yep, on my x86_64 system, it seems to be.

[    3.101115] usb 1-5: new high-speed USB device number 2 using ehci-pci
[    3.232309] usb 1-5: New USB device found, idVendor=0b95, idProduct=772b
[    3.232327] usb 1-5: New USB device strings: Mfr=1, Product=2, SerialNumber=3
[    3.232339] usb 1-5: Product: AX88772B
[    3.232350] usb 1-5: Manufacturer: ASIX Elec. Corp.
[    3.232360] usb 1-5: SerialNumber: 188298
[    4.032206] asix 1-5:1.0 eth1: register 'asix' at
usb-0000:00:04.1-5, ASIX AX88772B USB 2.0 Ethernet, 00:50:b6:18:82:98


> Please can you supply the output of ifconfig for the USB to Ethernet
> adaptor, your example above shows eth1 as the device.
>
> Please show the output of ifconfig eth1 before and after the issue is seen.
> This will show us whether the kernel logs any network errors and how many
> bytes have been transferred.

Before:
$ ifconfig eth1
eth1      Link encap:Ethernet  HWaddr 00:50:b6:18:82:98
          inet addr:192.168.0.12  Bcast:192.168.0.255  Mask:255.255.255.0
          inet6 addr: 2601:1c2:1002:83f0:250:b6ff:fe18:8298/64 Scope:Global
          inet6 addr: fe80::250:b6ff:fe18:8298/64 Scope:Link
          inet6 addr: 2601:1c2:1002:83f0:b0f0:71a0:6c7e:346b/64 Scope:Global
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:372 errors:0 dropped:0 overruns:0 frame:0
          TX packets:385 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:38523 (38.5 KB)  TX bytes:48801 (48.8 KB)


After:
$ ifconfig eth1
eth1      Link encap:Ethernet  HWaddr 00:50:b6:18:82:98
          inet addr:192.168.0.12  Bcast:192.168.0.255  Mask:255.255.255.0
          inet6 addr: 2601:1c2:1002:83f0:250:b6ff:fe18:8298/64 Scope:Global
          inet6 addr: fe80::250:b6ff:fe18:8298/64 Scope:Link
          inet6 addr: 2601:1c2:1002:83f0:b0f0:71a0:6c7e:346b/64 Scope:Global
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:151005 errors:169 dropped:0 overruns:0 frame:0
          TX packets:61351 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:225874384 (225.8 MB)  TX bytes:4431098 (4.4 MB)




> After the issue is seen, please can you show us the output of "dmesg | grep
> asix" so that we can see status messages from the ASIX driver that the USB
> to Ethernet adaptor is using. In particular we need to check that USB high
> speed operation (480Mbps) is being used and not full speed operation
> (12Mbps).


[    2.766525] usbcore: registered new interface driver asix
[    4.031443] asix 1-5:1.0 eth1: register 'asix' at
usb-0000:00:04.1-5, ASIX AX88772B USB 2.0 Ethernet, 00:50:b6:18:82:98
[   31.578983] asix 1-5:1.0 eth1: link down
[   33.244743] asix 1-5:1.0 eth1: link up, 100Mbps, full-duplex, lpa 0xCDE1
[  171.959244] asix 1-5:1.0 eth1: asix_rx_fixup() Data Header
synchronisation was lost, remaining 988
[  171.959530] asix 1-5:1.0 eth1: asix_rx_fixup() Bad Header Length
0x1651c2bf, offset 4
[  171.959768] asix 1-5:1.0 eth1: asix_rx_fixup() Bad Header Length
0xfcf61092, offset 4
[  171.960001] asix 1-5:1.0 eth1: asix_rx_fixup() Bad Header Length
0x3269b285, offset 4
[  171.960348] asix 1-5:1.0 eth1: asix_rx_fixup() Bad Header Length
0xdf3bd279, offset 4
[  171.976453] asix 1-5:1.0 eth1: asix_rx_fixup() Data Header
synchronisation was lost, remaining 988
[  171.976663] asix 1-5:1.0 eth1: asix_rx_fixup() Bad Header Length
0x8ad939e0, offset 4
[  171.976835] asix 1-5:1.0 eth1: asix_rx_fixup() Bad Header Length
0xeb99048f, offset 4
[  171.977002] asix 1-5:1.0 eth1: asix_rx_fixup() Bad Header Length
0x5d1ac177, offset 4
[  172.312002] asix 1-5:1.0 eth1: asix_rx_fixup() Data Header
synchronisation was lost, remaining 988
[  172.312319] asix 1-5:1.0 eth1: asix_rx_fixup() Bad Header Length
0x3722a6f0, offset 4
[  172.312503] asix 1-5:1.0 eth1: asix_rx_fixup() Bad Header Length
0x45371a3e, offset 4
[  172.312680] asix 1-5:1.0 eth1: asix_rx_fixup() Bad Header Length
0xc396c451, offset 4
[  173.066398] asix 1-5:1.0 eth1: asix_rx_fixup() Data Header
synchronisation was lost, remaining 988
[  173.066686] asix 1-5:1.0 eth1: asix_rx_fixup() Bad Header Length
0xa445167f, offset 4
[  173.066921] asix 1-5:1.0 eth1: asix_rx_fixup() Bad Header Length
0xa16d6b5b, offset 4
[  173.293636] asix 1-5:1.0 eth1: asix_rx_fixup() Data Header
synchronisation was lost, remaining 988
[  173.293904] asix 1-5:1.0 eth1: asix_rx_fixup() Bad Header Length
0xb1510dad, offset 4
[  173.294167] asix 1-5:1.0 eth1: asix_rx_fixup() Bad Header Length
0x22709710, offset 4
[  173.304459] asix 1-5:1.0 eth1: asix_rx_fixup() Data Header
synchronisation was lost, remaining 988
[  173.304679] asix 1-5:1.0 eth1: asix_rx_fixup() Bad Header Length
0x1472a821, offset 4
[  173.304861] asix 1-5:1.0 eth1: asix_rx_fixup() Bad Header Length
0x9e2b0c30, offset 4
[  173.305085] asix 1-5:1.0 eth1: asix_rx_fixup() Bad Header Length
0xcfe77e12, offset 4
[  173.305308] asix 1-5:1.0 eth1: asix_rx_fixup() Bad Header Length
0xfc5b890d, offset 4
...


thanks
-john
