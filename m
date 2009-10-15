From: Andrew Swan <Andrew.Swan@riverbed.com>
Subject: rx_buffer_len and LPE in intel drivers
Date: Thu, 15 Oct 2009 13:09:55 -0700
Message-ID: <9FE6702D-6B1E-4B89-BFC7-D855FB409C5A@riverbed.com>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset="US-ASCII"; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from eng.riverbed.com ([208.70.196.45]:57592 "EHLO
	smtp1.riverbed.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763005AbZJOUUc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2009 16:20:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi,

I've been looking at skbuff memory usage with e1000, e1000e, and igb  
and have a few questions related to some common code that sets  
rx_buffer_len to ~1500 bytes when LPE is disabled.

For context, there is a huge advantage to holding rx_buffer_len to  
~1500 bytes: a few hundred bytes of overhead are added to each skbuff  
allocation so when rx_buffer_len is ~1500, each allocation fits within  
the 2048 byte allocation slab.  In contrast, when rx_buffer_len is  
2048, the skb overhead means that the allocations get pushed into the  
4096 byte slab, doubling the memory consumed by a typical 1500 byte  
packet.

e1000 and e1000e both have code in _setup_rctl() to disable LPE when  
the mtu is <= 1500.  Then there is this related code in _change_mtu():

e1000:
	/* adjust allocation if LPE protects us, and we aren't using SBP */
	if (!hw->tbi_compatibility_on &&
	    ((max_frame == MAXIMUM_ETHERNET_FRAME_SIZE) ||
	     (max_frame == MAXIMUM_ETHERNET_VLAN_SIZE)))
		adapter->rx_buffer_len = MAXIMUM_ETHERNET_VLAN_SIZE;

e1000e:
	/* adjust allocation if LPE protects us, and we aren't using SBP */
	if ((max_frame == ETH_FRAME_LEN + ETH_FCS_LEN) ||
	     (max_frame == ETH_FRAME_LEN + VLAN_HLEN + ETH_FCS_LEN))
		adapter->rx_buffer_len = ETH_FRAME_LEN + VLAN_HLEN
					 + ETH_FCS_LEN;

My first question is about e1000 specifically -- it doesn't use this  
optimization if "tbi compatability" is on.  My understanding is that  
tbi compatability implies "store back packets" (SBP) is on and SBP  
overrides the discard of large packets when LPE is off.  But  
e1000_sw_init() initializes rx_buffer_len to ~1500 bytes, regardless  
of the tbi compatability setting.  I don't know exactly what tbi  
compatability is but is there a bug where a device that uses this mode  
comes up in an unsafe mode?  (i.e., the driver is allocating 1500 byte  
skb's but tbi compatability is on so the hardware may deliver large  
packets and overflow the skb?)

The larger question though is why both drivers test the mtu against  
these two specific values before using a smaller rx_buffer_len.  It  
seems that it would be safe to just use the test "if max_frame <=  
MAXIMUM_ETHERNET_VLAN_SIZE".  Or am I overlooking something else?

Finally, igb has the same logic as e1000 and e1000e in _change_mtu()  
but it is overriden by code in igb_setup_rctl() that unconditionally  
sets LPE and rounds rx_buffer_len up to a power of 2.  Is there some  
reason why it wouldn't be safe to implement the same logic from e1000  
and e1000e for clearing LPE and shrinking rx_buffer_len?

I'd be happy to provide patches for these fixes but want to make sure  
I'm on a reasonable path first..

Thanks!

-Andrew


