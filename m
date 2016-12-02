From: Andy Lutomirski <luto@kernel.org>
Subject: Re: [PATCH v8 3/8] thunderbolt: Communication with the ICM (firmware)
Date: Thu, 1 Dec 2016 17:21:01 -0800
Message-ID: <fe0f0a6f-488b-bbc0-8987-a9c47d9ed9b9@kernel.org>
References: <1475073870-2126-1-git-send-email-amir.jer.levy@intel.com>
 <1475073870-2126-4-git-send-email-amir.jer.levy@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: andreas.noever@gmail.com, bhelgaas@google.com, corbet@lwn.net,
        linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org,
        netdev@vger.kernel.org, linux-doc@vger.kernel.org,
        mario_limonciello@dell.com, thunderbolt-linux@intel.com,
        mika.westerberg@intel.com, tomas.winkler@intel.com,
        xiong.y.zhang@intel.com
To: Amir Levy <amir.jer.levy@intel.com>, gregkh@linuxfoundation.org
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <1475073870-2126-4-git-send-email-amir.jer.levy@intel.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/28/2016 07:44 AM, Amir Levy wrote:
> This patch provides the communication protocol between the
> Intel Connection Manager(ICM) firmware that is operational in the
> Thunderbolt controller in non-Apple hardware.
> The ICM firmware-based controller is used for establishing and maintaining
> the Thunderbolt Networking connection - we need to be able to communicate
> with it.

I'm a bit late to the party, but here goes.  I have two big questions:

1. Why is this using netlink at all?  A system has zero or more 
Thunderbolt controllers, they're probed just like any other PCI devices 
(by nhi_probe() if I'm understanding correctly), they'll have nodes in 
sysfs, etc.  Shouldn't there be a simple char device per Thunderbolt 
controller that a daemon can connect to?  This will clean up lots of things:

a) You can actually enforce one-daemon-at-a-time in a very natural way. 
Your current code seems to try, but it's rather buggy.  Your 
subscription count is a guess, your unsubscribe is entirely unchecked, 
and you are entirely unable to detect if a daemon crashes AFAICT.

b) You won't need all of the complexity that's currently there to figure 
out *which* Thunderbolt device a daemon is talking to.

c) You can use regular ioctl passing *structs* instead of netlink attrs. 
  There's nothing wrong with netlink attrs, except that your driver 
seems to have a whole lot of boilerplate that just converts back and 
forth to regular structures.

d) The userspace code that does stuff like "send message, wait 150ms, 
receive reply, complain if no reply" goes away because ioctl is 
synchronous.  (Or you can use read and write, but it's still simpler.)

e) You could have one daemon per Thunderbolt device if you were so inclined.

f) You get privilege separation in userspace.  Creating a netlink socket 
and dropping privilege is busted^Winteresting.  Opening a device node 
and dropping privilege works quite nicely.

2. Why do you need a daemon anyway.  Functionally, what exactly does it 
do?  (Okay, I get that it seems to talk to a giant pile of code running 
in SMM, and I get that Intel, for some bizarre reason, wants everyone 
except Apple to use this code in SMM, and that Apple (for entirely 
understandable reasons) turned it off, but that's beside the point. 
What does the user code do that's useful and that the kernel can't do 
all by itself?  The only really interesting bit I can see is the part 
that approves PCI devices.



I'm not going to review this in detail, but here's a tiny bit:

> +static int nhi_genl_unsubscribe(__always_unused struct sk_buff *u_skb,
> +				__always_unused struct genl_info *info)
> +{
> +	atomic_dec_if_positive(&subscribers);
> +
> +	return 0;
> +}
> +

This, for example, is really quite buggy.



This entire function here:

> +static int nhi_genl_query_information(__always_unused struct sk_buff *u_skb,
> +				      struct genl_info *info)
> +{
> +	struct tbt_nhi_ctxt *nhi_ctxt;
> +	struct sk_buff *skb;
> +	bool msg_too_long;
> +	int res = -ENODEV;
> +	u32 *msg_head;
> +
> +	if (!info || !info->userhdr)
> +		return -EINVAL;
> +
> +	skb = genlmsg_new(NLMSG_ALIGN(nhi_genl_family.hdrsize) +
> +			  nla_total_size(sizeof(DRV_VERSION)) +
> +			  nla_total_size(sizeof(nhi_ctxt->nvm_ver_offset)) +
> +			  nla_total_size(sizeof(nhi_ctxt->num_ports)) +
> +			  nla_total_size(sizeof(nhi_ctxt->dma_port)) +
> +			  nla_total_size(0),	/* nhi_ctxt->support_full_e2e */
> +			  GFP_KERNEL);
> +	if (!skb)
> +		return -ENOMEM;
> +
> +	msg_head = genlmsg_put_reply(skb, info, &nhi_genl_family, 0,
> +				     NHI_CMD_QUERY_INFORMATION);
> +	if (!msg_head) {
> +		res = -ENOMEM;
> +		goto genl_put_reply_failure;
> +	}
> +
> +	if (mutex_lock_interruptible(&controllers_list_mutex)) {
> +		res = -ERESTART;
> +		goto genl_put_reply_failure;
> +	}
> +
> +	nhi_ctxt = nhi_search_ctxt(*(u32 *)info->userhdr);
> +	if (nhi_ctxt && !nhi_ctxt->d0_exit) {
> +		*msg_head = nhi_ctxt->id;
> +
> +		msg_too_long = !!nla_put_string(skb, NHI_ATTR_DRV_VERSION,
> +						DRV_VERSION);
> +
> +		msg_too_long = msg_too_long ||
> +			       nla_put_u16(skb, NHI_ATTR_NVM_VER_OFFSET,
> +					   nhi_ctxt->nvm_ver_offset);
> +
> +		msg_too_long = msg_too_long ||
> +			       nla_put_u8(skb, NHI_ATTR_NUM_PORTS,
> +					  nhi_ctxt->num_ports);
> +
> +		msg_too_long = msg_too_long ||
> +			       nla_put_u8(skb, NHI_ATTR_DMA_PORT,
> +					  nhi_ctxt->dma_port);
> +
> +		if (msg_too_long) {
> +			res = -EMSGSIZE;
> +			goto release_ctl_list_lock;
> +		}
> +
> +		if (nhi_ctxt->support_full_e2e &&
> +		    nla_put_flag(skb, NHI_ATTR_SUPPORT_FULL_E2E)) {
> +			res = -EMSGSIZE;
> +			goto release_ctl_list_lock;
> +		}
> +		mutex_unlock(&controllers_list_mutex);
> +
> +		genlmsg_end(skb, msg_head);
> +
> +		return genlmsg_reply(skb, info);
> +	}
> +
> +release_ctl_list_lock:
> +	mutex_unlock(&controllers_list_mutex);
> +	genlmsg_cancel(skb, msg_head);
> +
> +genl_put_reply_failure:
> +	nlmsg_free(skb);
> +
> +	return res;
> +}

would be about three lines of code if you used copy_to_user and a struct.


--Andy
