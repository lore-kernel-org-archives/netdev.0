From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 1/3] perf, events: add non-linear data support
 for raw records
Date: Wed, 13 Jul 2016 15:16:37 +0200
Message-ID: <57863F35.2060501@iogearbox.net>
References: <cover.1468362046.git.daniel@iogearbox.net> <f6ffffc1011706426682be92f80fc6aa6a8cc196.1468362046.git.daniel@iogearbox.net> <20160713075209.GQ30154@twins.programming.kicks-ass.net> <578608BD.4080102@iogearbox.net> <20160713121036.GS30154@twins.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, alexei.starovoitov@gmail.com, tgraf@suug.ch,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160713121036.GS30154@twins.programming.kicks-ass.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/13/2016 02:10 PM, Peter Zijlstra wrote:
> On Wed, Jul 13, 2016 at 11:24:13AM +0200, Daniel Borkmann wrote:
>> On 07/13/2016 09:52 AM, Peter Zijlstra wrote:
>>> On Wed, Jul 13, 2016 at 12:36:17AM +0200, Daniel Borkmann wrote:
>>>> This patch adds support for non-linear data on raw records. It means
>>>> that for such data, the newly introduced __output_custom() helper will
>>>> be used instead of __output_copy(). __output_custom() will invoke
>>>> whatever custom callback is passed in via struct perf_raw_record_frag
>>>> to extract the data into the ring buffer slot.
>>>>
>>>> To keep changes in perf_prepare_sample() and in perf_output_sample()
>>>> minimal, size/size_head split was added to perf_raw_record that call
>>>> sites fill out, so that two extra tests in fast-path can be avoided.
>>>>
>>>> The few users of raw records are adapted to initialize their size_head
>>>> and frag data; no change in behavior for them. Later patch will extend
>>>> BPF side with a first user and callback for this facility, future users
>>>> could be things like XDP BPF programs (that work on different context
>>>> though and would thus have a different callback), etc.
>>>
>>> Why? What problem are we solving?
>>
>> I've tried to summarize it in patch 3/3,
>
> Which is pretty useless if you're staring at this patch.
>
>> This currently has 3 issues we'd like to resolve:
>
>> i) We need two copies instead of just a single one for the skb data.
>> The data can be non-linear, see also skb_copy_bits() as an example for
>> walking/extracting it,
>
> I'm not familiar enough with the network gunk to be able to read that.
> But upto skb_walk_frags() it looks entirely linear to me.

Hm, fair enough, there are three parts, skb can have a linear part
which is taken via skb->data, either in its entirety or there can be a
non-linear part appended to that which can consist of pages that are in
shared info section (skb_shinfo(skb) -> frags[], nr_frags members), that
will be linearized, and in addition to that, appended after the frags[]
data there can be further skbs to the 'root' skb that contain fragmented
data, which is all what skb_copy_bits() copies linearized into 'to' buffer.
So depending on the origin of the skb, its structure can be quite different
and skb_copy_bits() covers all the cases generically. Maybe [1] summarizes
it better if you want to familiarize yourself with how skbs work,
although some parts are not up to date anymore.

   [1] http://vger.kernel.org/~davem/skb_data.html

>> ii) for static verification reasons, the bpf_skb_load_bytes() helper
>> needs to see a constant size on the passed buffer to make sure BPF
>> verifier can do its sanity checks on it during verification time, so
>> just passing in skb->len (or any other non-constant value) wouldn't
>> work, but changing bpf_skb_load_bytes() is also not the real solution
>> since we still have two copies we'd like to avoid as well, and
>
>> iii) bpf_skb_load_bytes() is just for rather smaller buffers (e.g.
>> headers) since they need to sit on the limited eBPF stack anyway. The
>> set would improve the BPF helper to address all 3 at once.
>
> Humm, maybe. Lemme go try and reverse engineer that patch, because I'm
> not at all sure wth it's supposed to do, nor am I entirely sure this
> clarified things :/
