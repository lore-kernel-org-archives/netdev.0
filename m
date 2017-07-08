From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [RFC PATCH 08/12] bpf: add devmap, a map for storing net device
 references
Date: Sat, 8 Jul 2017 20:57:50 +0200
Message-ID: <20170708205750.152ca83e@redhat.com>
References: <20170707172115.9984.53461.stgit@john-Precision-Tower-5810>
        <20170707173712.9984.13243.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, andy@greyhouse.net,
        daniel@iogearbox.net, ast@fb.com, brouer@redhat.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44562 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753079AbdGHS56 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 8 Jul 2017 14:57:58 -0400
In-Reply-To: <20170707173712.9984.13243.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 07 Jul 2017 10:37:12 -0700
John Fastabend <john.fastabend@gmail.com> wrote:

> Device map (devmap) is a BPF map, primarily useful for networking
> applications, that uses a key to lookup a reference to a netdevice.
> 
> The map provides a clean way for BPF programs to build virtual port
> to physical port maps. Additionally, it provides a scoping function
> for the redirect action itself allowing multiple optimizations. Future
> patches will leverage the map to provide batching at the XDP layer.
> 
> Another optimization/feature, that is not yet implemented, would be
> to support multiple netdevices per key to support efficient multicast
> and broadcast support.

[...]

> diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
> index 74ea96e..06073ba 100644
> --- a/kernel/bpf/verifier.c
> +++ b/kernel/bpf/verifier.c
> @@ -1294,6 +1294,14 @@ static int check_map_func_compatibility(struct bpf_map *map, int func_id)
>  		    func_id != BPF_FUNC_current_task_under_cgroup)
>  			goto error;
>  		break;
> +	/* devmap returns a pointer to a live net_device ifindex that we cannot
> +	 * allow to be modified from bpf side. So do not allow lookup elemnts
                                                                      ^^^^^^^
Spelling of elements

> +	 * for now.
> +	 */
> +	case BPF_MAP_TYPE_DEVMAP:
> +		if (func_id == BPF_FUNC_map_lookup_elem)
> +			goto error;
> +		break;

Reviewer notice this limitation from the bpf_prog side.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
