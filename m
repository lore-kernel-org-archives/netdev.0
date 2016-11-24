From: Mark Lord <mlord@pobox.com>
Subject: Re: [PATCH net 1/2] r8152: fix the sw rx checksum is unavailable
Date: Thu, 24 Nov 2016 11:43:53 -0500
Message-ID: <23e0c132-8844-0a34-3e0b-e412f76493ba@pobox.com>
References: <95fa9f67-3af6-6749-0e2b-c95406486f7d@pobox.com>
 <baf5246d-9d8a-4029-6823-350ed561fd33@pobox.com>
 <0835B3720019904CB8F7AA43166CEEB201055ED8@RTITMBSV03.realtek.com.tw>
 <20161124.112152.692025478489876693.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
        linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: David Miller <davem@davemloft.net>, hayeswang@realtek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161124.112152.692025478489876693.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 16-11-24 11:21 AM, David Miller wrote:
> From: Hayes Wang <hayeswang@realtek.com>
> Date: Thu, 24 Nov 2016 13:26:55 +0000
>
>> I don't think the garbage results from our driver or device.
> This is my impression with what has been presented so far as well.

It's not garbage.

The latest run with the debug code I posted here earlier just spat out this below.
Using coherent (guarded, non-cacheable) RX buffers, with mb() calls:

[   15.199157] r8152_check_rx_desc: rx_desc looks bad.
[   15.204270] r8152_rx_bottom: offset=0/3376 bad rx_desc
[   15.209584] r8152_dump_rx_desc: 3d435253 3034336d 202f3a30 47524154 2f3d5445 3034336d rx_len=21075

The bad data in this case is ASCII:

         "SRC=m3400:/ TARGET=/m340"

This data is what is seen in /run/mount/utab, a file that is read/written over NFS on each boot.

         "SRC=m3400:/ TARGET=/m3400 ROOT=/ ATTRS=nolock,addr=192.168.8.1\n"

But how does this ASCII data end up at offset zero of the rx buffer??
Not possible -- this isn't even stale data, because only an rx_desc could
be at that offset in that buffer.

So even if this were a platform memory coherency issue, one should still
never see ASCII data at the beginning of an rx buffer.  The driver NEVER
writes anything to the rx buffers.  Only the USB hardware ever does.

And only the r8152 dongle/driver exhibits this issue.
Other USB dongles do not.  They *might* still have such issues,
but because they use software checksums, the bad packets are caught/rejected.

The r8152 driver, without the debug/error-checking additions, would have tried
to interpret that ASCII data as an "rx_desc", and would have interpreted the
"checksum bits" therein as "valid checksum", and the packet would have passed
through the network stack, corrupting data.

This driver worked without noticeable issues in 3.12.xx.
It hasn't worked since.  Because it now trusts the hardware checksums,
without first checking to see if noise-on-the-line or something else
has corrupted the data before receipt in the rx buffer.

Based on the above capture, I suspect a bug in the chip itself, which perhaps
is only manifest on a very slow CPU.

Nobody here tests with slow CPUs, but they are very prevalent in embedded space.
And very few people use USB network dongles nowadays either, as nearly all "computers"
have built-in networking.  The market for USB network dongles is mostly embedded space.

Ergo.

Cheers
