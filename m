From: Mark Lord <mlord-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net 1/2] r8152: fix the sw rx checksum is unavailable
Date: Wed, 23 Nov 2016 14:29:37 -0500
Message-ID: <95fa9f67-3af6-6749-0e2b-c95406486f7d@pobox.com>
References: <1394712342-15778-226-Taiwan-albertk@realtek.com>
 <1394712342-15778-227-Taiwan-albertk@realtek.com>
 <0835B3720019904CB8F7AA43166CEEB20105013E@RTITMBSV03.realtek.com.tw>
 <d683c019-4e0f-6fe6-368c-c4fc86c72fe6@pobox.com>
 <0835B3720019904CB8F7AA43166CEEB201050B7E@RTITMBSV03.realtek.com.tw>
 <b9809516-d036-bfc3-b7a3-6563033ec957@pobox.com>
 <0835B3720019904CB8F7AA43166CEEB2010517CE@RTITMBSV03.realtek.com.tw>
 <b61a0e10-c737-8912-3e4e-393f4eb32077@pobox.com>
 <0835B3720019904CB8F7AA43166CEEB201051D51@RTITMBSV03.realtek.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: nic_swsd <nic_swsd-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>,
        "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <0835B3720019904CB8F7AA43166CEEB201051D51-JIZ+AM9kKNzuvTFwvkocLypo8c9IxeqyAjHCUHv49ws@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 16-11-23 10:12 AM, Hayes Wang wrote:
> Mark Lord [mlord-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org]
> [...]
>> What does this code do:
>
>>> static void r8153_set_rx_early_size(struct r8152 *tp)
>>> {
>>>        u32 mtu = tp->netdev->mtu;
>>>        u32 ocp_data = (agg_buf_sz - mtu - VLAN_ETH_HLEN - VLAN_HLEN) / 4;
>>>
>>>        ocp_write_word(tp, MCU_TYPE_USB, USB_RX_EARLY_SIZE, ocp_data);
>>> }
>
> This only works for RTL8153. However, what you use is RTL8152.
> It is like delay completion. It is used to reduce the loading of CPU
> by letting a transfer contain more data to reduce the number of
> transfers.
>
>> How is ocp_data used by the hardware?
>> Shouldn't the calculation also include sizeof(rx_desc) in there somewhere?
>
> The algorithm is from our hw engineers, and it should be
>
>    (agg_buf_sz - packet size) / 8
>
> You could refer to commit a59e6d815226 ("r8152: correct the rx early size").

Thanks.

Right now I am working quite hard trying to narrow things down exactly.
You are correct that the driver does appear to be careful about accesses
beyond the filled portion of a URB buffer -- for some reason I thought
the original driver had issues there, but looking again it does not seem to.

One idea that is now looking more likely:
Things could be suffering from speculative CPU accesses to RAM
(the system here has non-coherent d-cache/RAM).
This could incorrectly pre-load data from adjacent URB buffers
into the d-cache, creating coherency issues.  I am testing now
with cacheline-sized guard zones between the buffers to see if
that is the issue or not.

Worth repeating: other dongles we have tried, eg. those using the asix driver,
do not cause us any troubles here.  Only the r8152 dongles do.

The other drivers do not use hardware checksums, so even if they did
incur similar bad packets, whatever the reason, those bad packets
would be detected/rejected by the Linux network stack (software checksums).
So everything appears to behave fine with them, as it does with
the r8152 driver when hardware checksums are disabled.

Still trying to understand exactly how these errors are happening.
It takes a very long time to do a conclusive test of anything here,
and I only have the hardware for a day or two a week.
So my apologies if I am slow in getting back to you on stuff.

Cheers



--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
