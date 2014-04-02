From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [PATCH net-next v2 2/2] xen-netback: Grant copy the
 header instead of map and memcpy
Date: Wed, 2 Apr 2014 14:11:59 +0100
Message-ID: <533C0C9F.8030205@citrix.com>
References: <1396278539-27639-1-git-send-email-zoltan.kiss@citrix.com>	<1396278539-27639-2-git-send-email-zoltan.kiss@citrix.com>
	<1396352440.8667.117.camel@kazak.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jonathan.davies@citrix.com, wei.liu2@citrix.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, paul.durrant@citrix.com,
	Zoltan Kiss <zoltan.kiss@citrix.com>, xen-devel@lists.xenproject.org
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <xen-devel-bounces@lists.xen.org>
In-Reply-To: <1396352440.8667.117.camel@kazak.uk.xensource.com>
List-Unsubscribe: <http://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <http://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Sender: xen-devel-bounces@lists.xen.org
Errors-To: xen-devel-bounces@lists.xen.org
List-Id: netdev.vger.kernel.org

On 01/04/14 12:40, Ian Campbell wrote:
> On Mon, 2014-03-31 at 16:08 +0100, Zoltan Kiss wrote:
>>  
>>  		__skb_put(skb, data_len);
>> +		vif->tx_copy_ops[*copy_ops].source.u.ref = txreq.gref;
>> +		vif->tx_copy_ops[*copy_ops].source.domid = vif->domid;
>> +		vif->tx_copy_ops[*copy_ops].source.offset = txreq.offset;
>> +
>> +		vif->tx_copy_ops[*copy_ops].dest.u.gmfn =
>> +			virt_to_mfn(skb->data);
>> +		vif->tx_copy_ops[*copy_ops].dest.domid = DOMID_SELF;
>> +		vif->tx_copy_ops[*copy_ops].dest.offset =
>> +			offset_in_page(skb->data);
>> +
>> +		vif->tx_copy_ops[*copy_ops].len = data_len;
>> +		vif->tx_copy_ops[*copy_ops].flags = GNTCOPY_source_gref;
> 
> We have gnttab_set_map_op. Should we have gnttap_set_copy_op too?

A set of 3 might be useful I think.

gnttab_set_copy_op_ref_to_gfn()
gnttab_set_copy_op_gfn_to_ref()
gnttab_set_copy_op_ref_to_ref()

> 
>> -	BUG_ON(ret);
>> +	else {
>> +		gnttab_batch_copy(vif->tx_copy_ops, nr_cops);
>> +		if (nr_mops != 0) {
> 
> 
> if (nr_mops) would do.
> 
>> +			ret = gnttab_map_refs(vif->tx_map_ops,
> 
> So we use gnttab_batch_copy and gnttab_map_refs.
> 
> Shouldn't we either use gnttab_batch_copy and gnttab_batch_map or
> gnttab_copy gnttab_map_refs. (where gnttab_copy might be a bare
> GNTTABOP_copy or might be a helper wrapper).

gnttab_batch_map() is not correct here since it does not update the p2m.
 There is only one copy API (gnttab_batch_copy()).

> The point of the batch interface is to handle page unsharing etc, but
> doing it only for copies seems like a waste one way or another.

Both mapping and copy need to handle (hypervisor) paging/shaing and the
two calls Zoli has used do this.

gnttab_map_refs() is basically gnttab_batch_map() +
set_foreign_p2m_mapping().

I'd be in favour of a patch that:

- renamed gnttab_map_refs() to gnttab_batch_map_pages()
- refactored it to call gnttab_batch_map().
- added documentation

But I don't see why this would be a prerequisite for this series.

David
