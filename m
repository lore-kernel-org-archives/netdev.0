From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next] ixgbevf: fix 'Etherleak' in ixgbevf
Date: Thu, 22 Dec 2016 09:55:03 -0800
Message-ID: <CAKgT0Uffy-PEqTEKdFDeb_v=vF24wpn8JkKQdUhOPTKNuTuBkw@mail.gmail.com>
References: <1481802034-77729-1-git-send-email-chenweilong@huawei.com>
 <CAKgT0UfA9VG4NQZLLxXvobtfp22yPpPssSM4Ge94KFa1RVnhyg@mail.gmail.com>
 <5c942aba-f7fb-ede6-b6a2-e591025f53a5@huawei.com> <CAKgT0Uf_HXtJiZJsEYm9L19cZ+deVX=E+Y8JvU5+u0=bggpAqw@mail.gmail.com>
 <ee9ad90d-1c4b-7358-a172-8369a0c7da8b@huawei.com> <CAKgT0Uf+hV=TDvNTqFz0aiKQ+iio7VhBc5pusc4aDtFAVbREpA@mail.gmail.com>
 <74e1e76d-40f6-db8e-74ac-90b0474d4e11@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Weilong Chen <chenweilong@huawei.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
        Netdev <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Kefeng Wang <wangkefeng.wang@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <74e1e76d-40f6-db8e-74ac-90b0474d4e11@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Yes that is much more helpful.  So looking at it things are being
padded but the last 4 bytes always have this extra data in them.  I've
been trying to recreate the issue on an 82599 with an SR-IOV VF and I
haven't been having much luck reproducing the problem.

In your test environment is the 82599 connected directly to the
Windows machine or are there any
switches/routers/gateways/tunnels/vlans in between?  I've tried
several iterations but with the 82599 connected directly to another
NIC I have I am not able to get it to produce the garbage padding you
are seeing. It makes me wonder if there might be something that is
manipulating the packets in between the two systems.  For example if
there was a VLAN being associated with the VF that is later stripped
and then the packet handed raw to the test system it might explain
what is introducing the extra padding and reason for pulling in the
CRC, and your patch would mask the issue since it would push the
minimum frame size with a VLAN to 68 instead of 64.

- Alex

On Wed, Dec 21, 2016 at 6:00 PM, Kefeng Wang <wangkefeng.wang@huawei.com> wrote:
>
>
> On 2016/12/21 10:20, Alexander Duyck wrote:
>> I find it curious that only the last 4 bytes have data in them.  I'm
>> wondering if the NIC/driver in the Windows/Nessus system is
>> interpreting the 4 byte CRC on the end of the frame as padding instead
>> of stripping it.
>>
>> Is there any chance you could capture the entire frame instead of just
>> the padding?  Maybe you could run something like wireshark without
>> enabling promiscuous mode on the VF and capture the frames it is
>> trying to send and receive.  What I want to verify is what the actual
>> amount of padding is that is needed to get to 60 bytes and where the
>> CRC should start.
>>
>> - Alex
>
> Here is the verbose output, is this useful?
> Or we will try according to your advice, thanks,
>
> D:\Program Files\Tenable\Nessus>nasl.exe -aX -t 192.169.0.151 etherleak.nasl
> --------------------------
>  ---[ ICMP ]---
> 0x00:  45 00 00 1D 20 81 00 00 40 01 D7 F3 C0 A9 00 97    E... ...@.......
> 0x10:  C0 A9 00 82 00 00 87 FD 00 01 00 01 78 00 00 00    ............x...
> 0x20:  00 00 00 00 00 00 00 00 00 00 98 E4 75 DF          ............u.
> --------------------------
>  ---[ ICMP ]---
> 0x00:  45 00 00 1D 20 85 00 00 40 01 D7 EF C0 A9 00 97    E... ...@.......
> 0x10:  C0 A9 00 82 00 00 87 FD 00 01 00 01 78 00 00 00    ............x...
> 0x20:  00 00 00 00 00 00 00 00 00 00 FB DA F8 13          ..............
> ---[ ether1 ]---
> 0x00:  00 00 00 00 00 00 00 00 00 00 00 00 00 98 E4 75    ...............u
> 0x10:  DF                                                 .
> ---[ ether2 ]---
> 0x00:  00 00 00 00 00 00 00 00 00 00 00 00 00 FB DA F8    ................
> 0x10:  13                                                 .
>
> Padding observed in one frame :
>
>   0x00:  00 00 00 00 00 00 00 00 00 00 00 00 00 98 E4 75    ...............u
>   0x10:  DF                                                 .
>
> Padding observed in another frame :
>
>   0x00:  00 00 00 00 00 00 00 00 00 00 00 00 00 FB DA F8    ................
>   0x10:  13
>
>
