From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH v3 6/6] virtio_net: xdp, add slowpath case for
 non contiguous buffers
Date: Tue, 29 Nov 2016 18:50:18 -0800
Message-ID: <583E3E6A.8050706@gmail.com>
References: <20161129200933.26851.41883.stgit@john-Precision-Tower-5810>
 <20161129201133.26851.31803.stgit@john-Precision-Tower-5810>
 <20161130003756.GD28238@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, daniel@iogearbox.net,
        shm@cumulusnetworks.com, davem@davemloft.net, tgraf@suug.ch,
        john.r.fastabend@intel.com, netdev@vger.kernel.org,
        bblanco@plumgrid.com, brouer@redhat.com
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:34188 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751913AbcK3Cuj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 21:50:39 -0500
Received: by mail-pg0-f68.google.com with SMTP id e9so18116449pgc.1
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2016 18:50:39 -0800 (PST)
In-Reply-To: <20161130003756.GD28238@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-11-29 04:37 PM, Alexei Starovoitov wrote:
> On Tue, Nov 29, 2016 at 12:11:33PM -0800, John Fastabend wrote:
>> virtio_net XDP support expects receive buffers to be contiguous.
>> If this is not the case we enable a slowpath to allow connectivity
>> to continue but at a significan performance overhead associated with
>> linearizing data. To make it painfully aware to users that XDP is
>> running in a degraded mode we throw an xdp buffer error.
>>
>> To linearize packets we allocate a page and copy the segments of
>> the data, including the header, into it. After this the page can be
>> handled by XDP code flow as normal.
>>
>> Then depending on the return code the page is either freed or sent
>> to the XDP xmit path. There is no attempt to optimize this path.
>>
>> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ...
>> +/* The conditions to enable XDP should preclude the underlying device from
>> + * sending packets across multiple buffers (num_buf > 1). However per spec
>> + * it does not appear to be illegal to do so but rather just against convention.
>> + * So in order to avoid making a system unresponsive the packets are pushed
>> + * into a page and the XDP program is run. This will be extremely slow and we
>> + * push a warning to the user to fix this as soon as possible. Fixing this may
>> + * require resolving the underlying hardware to determine why multiple buffers
>> + * are being received or simply loading the XDP program in the ingress stack
>> + * after the skb is built because there is no advantage to running it here
>> + * anymore.
>> + */
> ...
>>  		if (num_buf > 1) {
>>  			bpf_warn_invalid_xdp_buffer();
			^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Here is the warn once call. I made it a defined bpf warning so that we
can easily identify if needed and it can be used by other drivers as
well.

>> -			goto err_xdp;
>> +
>> +			/* linearize data for XDP */
>> +			xdp_page = xdp_linearize_page(rq, num_buf,
>> +						      page, offset, &len);
>> +			if (!xdp_page)
>> +				goto err_xdp;
> 
> in case when we're 'lucky' the performance will silently be bad.

Were you specifically worried about the alloc failing here and no
indication? I was thinking a statistic counter could be added as a
follow on series to catch this and other such cases in non XDP paths
if needed.

> Can we do warn_once here? so at least something in dmesg points out
> that performance is not as expected. Am I reading it correctly that
> you had to do a special kernel hack to trigger this situation and
> in all normal cases it's not the case?
> 

Correct the only way to produce this with upstream qemu and Linux is to
write a kernel hack to build these types of buffers. AFAIK I caught all
the cases where it could happen otherwise in the setup xdp prog call and
required user to configure device driver so they can not happen e.g.
disable LRO, set MTU < PAGE_SIZE, etc.

If I missed anything, I don't see it now, I would call it a bug and fix
it. Again AFAIK everything should be covered though. As Micheal pointed
out earlier although unexpected its not strictly against virtio spec to
build such packets so we should handle it at least in a degraded mode
even though it is not expected in any qemu cases.

.John
