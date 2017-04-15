From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next] Add uid and cookie bpf helper to cg_skb_func_proto
Date: Sat, 15 Apr 2017 02:20:36 +0200
Message-ID: <58F16754.80401@iogearbox.net>
References: <1492211534-6363-1-git-send-email-chenbofeng.kernel@gmail.com> <20170415000752.GC68140@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Lorenzo Colitti <lorenzo@google.com>,
        Willem de Bruijn <willemb@google.com>,
        Chenbo Feng <fengc@google.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Chenbo Feng <chenbofeng.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:55390 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755854AbdDOAUo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Apr 2017 20:20:44 -0400
In-Reply-To: <20170415000752.GC68140@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/15/2017 02:07 AM, Alexei Starovoitov wrote:
> On Fri, Apr 14, 2017 at 04:12:14PM -0700, Chenbo Feng wrote:
>> From: Chenbo Feng <fengc@google.com>
>>
>> BPF helper functions get_socket_cookie and get_socket_uid can be
>> used for network traffic classifications, among others. Expose
>> them also to programs of type BPF_PROG_TYPE_CGROUP_SKB. As of
>> commit 8f917bba0042 ("bpf: pass sk to helper functions") the required
>> skb->sk function is available at both cgroup bpf ingress and egress
>> hooks.
>>
>> Signed-off-by: Chenbo Feng <fengc@google.com>
>
> Thanks for follow up.
> Another alternative is to do
> cg_skb_func_proto(enum bpf_func_id func_id)
> {
>      return sk_filter_func_proto(func_id);
> }
>
> I think all socket filter helpers are applicable to cg_skb too.

Yeah, both will effectively be the same at that point:

static const struct bpf_func_proto *
sk_filter_func_proto(enum bpf_func_id func_id)
{
	switch (func_id) {
	case BPF_FUNC_skb_load_bytes:
		return &bpf_skb_load_bytes_proto;
	case BPF_FUNC_get_socket_cookie:
		return &bpf_get_socket_cookie_proto;
	case BPF_FUNC_get_socket_uid:
		return &bpf_get_socket_uid_proto;
	default:
		return bpf_base_func_proto(func_id);
	}
}

And with the two additions:

static const struct bpf_func_proto *
cg_skb_func_proto(enum bpf_func_id func_id)
{
	switch (func_id) {
	case BPF_FUNC_skb_load_bytes:
		return &bpf_skb_load_bytes_proto;
+	case BPF_FUNC_get_socket_cookie:
+		return &bpf_get_socket_cookie_proto;
+	case BPF_FUNC_get_socket_uid:
+		return &bpf_get_socket_uid_proto;
	default:
		return bpf_base_func_proto(func_id);
	}
}
