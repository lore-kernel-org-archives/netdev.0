From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [net-next-2.6 PATCH 02/10] ethtool: add ntuple flow specifier
 to network flow classifier
Date: Fri, 04 Mar 2011 11:30:36 -0800
Message-ID: <4D713DDC.4060109@intel.com>
References: <20110225232357.7920.58559.stgit@gitlad.jf.intel.com> <20110225233249.7920.70334.stgit@gitlad.jf.intel.com> <1298682048.3555.18.camel@localhost> <AANLkTi=P0v1+h=TjC2j5k0zM-2BF22tbaoGpKBAjNd7-@mail.gmail.com> <1299091805.2664.16.camel@bwh-desktop> <8A71B368A89016469F72CD08050AD334091C1FAB@maui.asicdesigners.com> <1299094046.2664.31.camel@bwh-desktop> <8A71B368A89016469F72CD08050AD334091C1FCF@maui.asicdesigners.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Dimitrios Michailidis <dm@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:62298 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759986Ab1CDTah (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Mar 2011 14:30:37 -0500
In-Reply-To: <8A71B368A89016469F72CD08050AD334091C1FCF@maui.asicdesigners.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/2/2011 12:03 PM, Dimitrios Michailidis wrote:
> Ben Hutchings wrote:
>> On Wed, 2011-03-02 at 11:11 -0800, Dimitrios Michailidis wrote:
>>> Ben Hutchings wrote:
>>>> /**
>>>>   * struct ethtool_flow_ext - flow spec common extension fields
>>>>   * @vlan_etype: EtherType for vlan tagged packet to match
>>>>   * @vlan_tci: VLAN tag to match
>>>>   * @data: Driver-dependent data to match
>>>>   *
>>>>   * Note: Additional fields may be inserted before @vlan_etype in future,
>>>>   * but the offset of the existing fields within the containing structure
>>>>   * (&struct ethtool_rx_flow_spec) will be stable.
>>>>   */
>>>> struct ethtool_flow_ext {
>>>> 	__be16	vlan_etype;
>>>> 	__be16	vlan_tci;
>>>> 	__be32	data[2];
>>>> };
>>>
>>> I am wondering about the semantics of these vlan_* fields.  Is vlan_etype the
>>> Ethertype in the VLAN header or the type after it?
>>
>> It would be the the type in the VLAN tag.  The nested ethertype is
>> normally implied by flow_type to be ETH_P_IP.
>>
>> This does leave the question of what this would mean:
>>
>> struct ethtool_rx_flow_spec fs = {
>> 	.flow_type = ... | FLOW_EXT,
>> 	...
>> 	.h_ext.vlan_tci = htons(0x1234),
>> 	.m_ext.vlan_etype = 0xffff,
>> };
>>
>> This says the TCI must be == 0x1234 but the type can be anything.  But
>> the type surely has to be be one assigned for use in VLAN tags.  Should
>> we leave it to the driver/hardware to determine what those valid types
>> are, or should we reject this as valid?
>
> Right.  Devices have some internal rules for what qualifies as a VLAN frame.
> If users are given the option to specify vlan_etype what do they get?
> At least we need to specify what is expected so drivers can decide if they can support it.

The basic idea I had is similar to what Ben described.  Basically the 
vlan_etype can be used to determine the Ethertype for the VLAN to be 
compared.  The reason for this is specifically the VLAN 0 case since 
without the VLAN Ethertype check VLAN 0 on ixgbe hardware will match an 
untagged frame and that may not be a desired result.  As such we can 
specify the VLAN Ethertype and then we will only match VLAN tagged 
frames without any false hits.

Thanks,

Alex

