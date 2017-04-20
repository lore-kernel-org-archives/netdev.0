From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: __sk_buff.data_end
Date: Thu, 20 Apr 2017 16:17:45 +0200
Message-ID: <1492697865.3109.7.camel@sipsolutions.net>
References: <1492637460.22185.6.camel@sipsolutions.net>
                         (sfid-20170419_233114_060429_CAFE85B8) <1492640459.22185.7.camel@sipsolutions.net>
                 <58F7FA6D.5030000@iogearbox.net>
         <1492668065.3109.1.camel@sipsolutions.net> <58F8C160.6010905@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: netdev <netdev@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>,
        Alexei Starovoitov <ast@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:57312 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S944018AbdDTOR6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 20 Apr 2017 10:17:58 -0400
In-Reply-To: <58F8C160.6010905@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-04-20 at 16:10 +0200, Daniel Borkmann wrote:
> 
> I think this would be a rather more complex operation on the BPF
> side, it would need changes from LLVM (which assumes initial ctx sits
> in r1), verifier for tracking this ctx2, all the way down to JITs
> plus some way to handle 1 and 2 argument program calls generically.
> Much easier to pass additional meta data for the program via cb[],
> for example.

Yeah, it did seem very complex :)

> > Alternatively I can clear another pointer (u64) in the CB, store a
> > pointer there, and always emit code following that pointer - should
> > be possible right?
> 
> What kind of pointer? If it's something like data_end as read-only,
> then this needs to be tracked in the verifier in addition, of course.
> Other option you could do (depending on what you want to achieve) is
> to have a bpf_probe_read() version as a helper for your prog type
> that would further walk that pointer/struct (similar to tracing)
> where this comes w/o any backward compat guarantees, though.

I meant something like this

struct wifi_cb {
	struct wifi_data *wifi_data;
	...
	void *data_end; // with BUILD_BUG_ON to the right offset
};

Then struct wifi_data can contain extra data that doesn't fit into
wifi_cb, like the stuff I evicted for *data_end and *wifi_data. Let's
say one of those fields is "u64 boottime_ns;" (as I did in my patch
now), so we have

struct wifi_data {
	u64 boottime_ns;
};

then I can still have

struct __wifi_sk_buff {
	u32 len;
	u32 data;
	u32 data_end;
	u32 boottime_ns; // this is strange but
			 // seems to be done this way?
};

And then when boottime_ns is accessed, I can have:

        case offsetof(struct __wifi_sk_buff, boottime_ns):
                off  = si->off;
                off -= offsetof(struct __wifi_sk_buff, boottime_ns);
                off += offsetof(struct sk_buff, cb);
                off += offsetof(struct wifi_cb, wifi_data);
                *insn++ = BPF_LDX_MEM(BPF_SIZEOF(void *), si->dst_reg,
                                      si->src_reg, off);
		off = offsetof(struct wifi_data, boottime_ns);
		*isns++ = BPF_LDX_MEM(BPF_SIZEOF(u64), si->dst_reg,
				      si->src_reg, off);
                break;

no?

It seems to me this should work, and essentially emit code to follow
the pointer to inside struct wifi_data. Assuming 

johannes
