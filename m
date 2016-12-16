From: "Vishwanathapura, Niranjana" <niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC v2 03/10] IB/hfi-vnic: Virtual Network Interface Controller
 (VNIC) netdev
Date: Thu, 15 Dec 2016 18:59:47 -0800
Message-ID: <20161216025947.GC90951@knc-06.sc.intel.com>
References: <1481788782-89964-1-git-send-email-niranjana.vishwanathapura@intel.com>
 <1481788782-89964-4-git-send-email-niranjana.vishwanathapura@intel.com>
 <20161215170109.GC3264@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
        ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, Sadanand Warrier <sadanand.warrier-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Sudeep Dutt <sudeep.dutt-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Tanya K Jajodia <tanya.k.jajodia-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Andrzej Kacprowski <andrzej.kacprowski-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20161215170109.GC3264-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 15, 2016 at 10:01:09AM -0700, Jason Gunthorpe wrote:
>On Wed, Dec 14, 2016 at 11:59:35PM -0800, Vishwanathapura, Niranjana wrote:
>> +/**
>> + * union hfi_vnic_bypass_hdr - VNIC bypass header
>> + * @slid: source lid
>> + * @length: length of packet
>> + * @becn: backward explicit congestion notification
>> + * @dlid: destination lid
>> + * @sc: service class
>> + * @fecn: forward explicit congestion notification
>> + * @l2: L2 type (2=16B)
>> + * @lt: link transfer field
>> + * @l4: L4 type
>> + * @slid_high: upper 4 bits of source lid
>> + * @dlid_high: upper 4 bits of destination lid
>> + * @pkey: partition key
>> + * @entropy: entropy
>> + * @age: packet age
>> + * @l4_hdr: L4 header
>> + */
>> +union hfi_vnic_bypass_hdr {
>> +	struct {
>> +	struct {
>> +		uint64_t slid   : 20;
>> +		uint64_t length : 11;
>> +		uint64_t becn   : 1;
>> +		uint64_t dlid   : 20;
>> +		uint64_t sc     : 5;
>> +		uint64_t rsvd   : 3;
>> +		uint64_t fecn   : 1;
>> +		uint64_t l2     : 2;
>> +		uint64_t lt     : 1;
>> +	};
>> +	struct {
>> +		uint64_t l4        : 8;
>> +		uint64_t slid_high : 4;
>> +		uint64_t dlid_high : 4;
>> +		uint64_t pkey      : 16;
>> +		uint64_t entropy   : 16;
>> +		uint64_t age       : 8;
>> +		uint64_t rsvd1     : 8;
>> +	};
>> +	struct {
>> +		uint32_t rsvd2  : 16;
>> +		uint32_t l4_hdr : 16;
>> +	};
>> +	} __packed;
>> +	u32 dw[5];
>> +};
>
>This isn't going to work on BE, please fix it.
>

We have made the hfi_vnic driver dependent on CONFIG_X86_64.
But I agree with all the feedback here. I will remove bitfields
and instead use bit operations in the next revision.

>> +/**
>> + * struct __hfi_vesw_info - HFI vnic virtual switch info
>> + */
>> +struct __hfi_vesw_info {
>> +	u16  fabric_id;
>> +	u16  vesw_id;
>> +
>> +	u8   rsvd0[6];
>> +	u16  def_port_mask;
>> +
>> +	u8   rsvd1[2];
>> +	u16  pkey;
>> +
>> +	u8   rsvd2[4];
>> +	u32  u_mcast_dlid;
>> +	u32  u_ucast_dlid[HFI_VESW_MAX_NUM_DEF_PORT];
>> +
>> +	u8   rsvd3[44];
>> +	u16  eth_mtu[HFI_VNIC_MAX_NUM_PCP];
>> +	u16  eth_mtu_non_vlan;
>> +	u8   rsvd4[2];
>> +} __packed;
>
>This goes on the network too? Also looks like it has endian problems.
>
>Ditto for all the __packed structures.
>

This is in CPU format. There is a separate big endian version of this structure 
defined in hfi_vnic_encap.h in below patch (which gets sent on wire).
https://www.spinics.net/lists/linux-rdma/msg44111.html

>> +#define v_dbg(format, arg...) \
>> +	netdev_dbg(adapter->netdev, format, ## arg)
>> +#define v_err(format, arg...) \
>> +	netdev_err(adapter->netdev, format, ## arg)
>> +#define v_info(format, arg...) \
>> +	netdev_info(adapter->netdev, format, ## arg)
>> +#define v_warn(format, arg...) \
>> +	netdev_warn(adapter->netdev, format, ## arg)
>
>Relies on an 'adapter' local varable?? Ugly.
>

I am using the same approach as Intel NIC driver like e1000e and ixgbe.

>Jason
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
