From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next 2/4] packet: add eBPF fanout mode
Date: Fri, 14 Aug 2015 10:03:16 -0700
Message-ID: <55CE1F54.7090109@plumgrid.com>
References: <1439567427-19504-1-git-send-email-willemb@google.com>
 <1439567427-19504-3-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, edumazet@google.com, dborkman@redhat.com
To: Willem de Bruijn <willemb@google.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:35891 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755113AbbHNRDS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Aug 2015 13:03:18 -0400
Received: by pacrr5 with SMTP id rr5so64014151pac.3
        for <netdev@vger.kernel.org>; Fri, 14 Aug 2015 10:03:18 -0700 (PDT)
In-Reply-To: <1439567427-19504-3-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/14/15 8:50 AM, Willem de Bruijn wrote:
> +static int fanout_set_data_ebpf(struct packet_fanout *f, char __user *data,
> +				unsigned int len)
> +{
> +	struct bpf_prog *new;
> +	u32 fd;
> +
> +	if (len != sizeof(fd))
> +		return -EINVAL;
> +	if (copy_from_user(&fd, data, len))
> +		return -EFAULT;
> +
> +	new = bpf_prog_get(fd);
> +	if (IS_ERR(new))
> +		return PTR_ERR(new);
> +
> +	__fanout_set_data_bpf(f, new);
> +	return 0;
> +}

all looks great except in the above the check:
         if (new->type != BPF_PROG_TYPE_SOCKET_FILTER) {
                 bpf_prog_put(new);
                 return -EINVAL;
         }
is missing. Otherwise user will be able to attach programs
of wrong types to fanout.

Also instead of:
  #define PACKET_FANOUT_BPF		6
  #define PACKET_FANOUT_EBPF		7

I would call them FANOUT_CBPF and FANOUT_EBPF to be unambiguous.
This is how bpf manpage distinguishes them.
