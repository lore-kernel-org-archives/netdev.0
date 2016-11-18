From: Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
Subject: RE: [PATCH net 1/2] r8152: fix the sw rx checksum is unavailable
Date: Fri, 18 Nov 2016 07:57:33 +0000
Message-ID: <0835B3720019904CB8F7AA43166CEEB201050B7E@RTITMBSV03.realtek.com.tw>
References: <1394712342-15778-226-Taiwan-albertk@realtek.com>
 <1394712342-15778-227-Taiwan-albertk@realtek.com>
 <0835B3720019904CB8F7AA43166CEEB20105013E@RTITMBSV03.realtek.com.tw>
 <d683c019-4e0f-6fe6-368c-c4fc86c72fe6@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: nic_swsd <nic_swsd-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>,
        "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Mark Lord <mlord-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <d683c019-4e0f-6fe6-368c-c4fc86c72fe6-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Content-Language: zh-TW
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Mark Lord [mailto:mlord-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org]
> Sent: Thursday, November 17, 2016 9:42 PM
[...]
> What the above sample shows, is the URB transfer buffer ran out of space in the
> middle
> of a packet, and the hardware then tried to just continue that same packet in the
> next URB,
> without an rx_desc header inserted.  The r8152.c driver always assumes the URB
> buffer begins
> with an rx_desc, so of course this behaviour produces really weird effects, and
> system crashes, etc..

The USB device wouldn't know the address and size of buffer. Only
the USB host controller knows. Therefore, the device sends the
data to host, and the host fills the memory. According to your
description, it seems the host splits the data from the device
into two different buffers (or URB transfers). I wonder if it would
occur. As far as I know, the host wouldn't allow the buffer size
less than the data length.

Our hw engineers need the log from the USB analyzer to confirm
what the device sends to the host. However, I don't think you
have USB analyzer to do this. I would try to reproduce the issue.
But, I am busy, so I don't think I would response quickly.

Besides, the maximum data length which the RTL8152 would send to
the host is 16KB. That is, if the agg_buf_sz is 16KB, the host
wouldn't split it. However, you still see problems for it.

[...]
> It is not clear to me how the chip decides when to forward an rx URB to the host.
> If you could describe how that part works for us, then it would help in further
> understanding why fast systems (eg. a PC) don't generally notice the issue,
> while much slower embedded systems do see the issue regularly.

The driver expects the rx buffer would be

	rx_desc + a packet + padding to 8 alignment + 
	rx_desc + a packet + padding to 8 alignment + ...
	
Therefore, when a urb transfer is completed, the driver parsers
the buffer by this way. After the buffer is handled, it would
be submitted to the host, until the transfer is completed again.
If the submitting fail, the driver would try again later. The
urb->actual_length means how much data the host fills. The drive
uses it to check the end of the data. The urb->status mean if
the transfer is successful. The driver submits the urb to the
host directly if the status is not successful.

Best Regards,
Hayes

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
