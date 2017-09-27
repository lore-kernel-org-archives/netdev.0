From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH v2 net-next 2/2] net/sched: allow flower to match tunnel
 options
Date: Wed, 27 Sep 2017 16:19:11 +0200
Message-ID: <20170927141911.GK1944@nanopsycho.orion>
References: <20170927091005.GB1944@nanopsycho.orion>
 <20170927092732.GC25449@vergenet.net>
 <20170927110822.GD1944@nanopsycho.orion>
 <20170927125205.GA30000@vergenet.net>
 <20170927125603.GH1944@nanopsycho.orion>
 <20170927133731.GA14183@vergenet.net>
 <20170927134750.GI1944@nanopsycho.orion>
 <20170927135042.GB14183@vergenet.net>
 <20170927140011.GJ1944@nanopsycho.orion>
 <20170927140952.GC14183@vergenet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, Jiri Pirko <jiri@mellanox.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org,
        oss-drivers@netronome.com, amir@vadai.me
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:48298 "EHLO
        mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752439AbdI0OTN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2017 10:19:13 -0400
Received: by mail-wm0-f46.google.com with SMTP id m127so18896789wmm.3
        for <netdev@vger.kernel.org>; Wed, 27 Sep 2017 07:19:13 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170927140952.GC14183@vergenet.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Sep 27, 2017 at 04:09:54PM CEST, simon.horman@netronome.com wrote:
>On Wed, Sep 27, 2017 at 04:00:11PM +0200, Jiri Pirko wrote:
>> Wed, Sep 27, 2017 at 03:50:44PM CEST, simon.horman@netronome.com wrote:
>> >On Wed, Sep 27, 2017 at 03:47:50PM +0200, Jiri Pirko wrote:
>> >> Wed, Sep 27, 2017 at 03:37:33PM CEST, simon.horman@netronome.com wrote:
>> >> >On Wed, Sep 27, 2017 at 02:56:03PM +0200, Jiri Pirko wrote:
>> >> >> Wed, Sep 27, 2017 at 02:52:06PM CEST, simon.horman@netronome.com wrote:
>> >> >> >On Wed, Sep 27, 2017 at 01:08:22PM +0200, Jiri Pirko wrote:
>> >> >> >> Wed, Sep 27, 2017 at 11:27:33AM CEST, simon.horman@netronome.com wrote:
>> >> >> >> >On Wed, Sep 27, 2017 at 11:10:05AM +0200, Jiri Pirko wrote:
>> >> >> >> >> Wed, Sep 27, 2017 at 10:16:34AM CEST, simon.horman@netronome.com wrote:
>> >> >> >
>> >> >> >...
>> >> >> >
>> >> >> >> >> > enum flow_dissector_key_id {
>> >> >> >> >> > 	FLOW_DISSECTOR_KEY_CONTROL, /* struct flow_dissector_key_control */
>> >> >> >> >> > 	FLOW_DISSECTOR_KEY_BASIC, /* struct flow_dissector_key_basic */
>> >> >> >> >> >@@ -205,6 +217,7 @@ enum flow_dissector_key_id {
>> >> >> >> >> > 	FLOW_DISSECTOR_KEY_MPLS, /* struct flow_dissector_key_mpls */
>> >> >> >> >> > 	FLOW_DISSECTOR_KEY_TCP, /* struct flow_dissector_key_tcp */
>> >> >> >> >> > 	FLOW_DISSECTOR_KEY_IP, /* struct flow_dissector_key_ip */
>> >> >> >> >> >+	FLOW_DISSECTOR_KEY_ENC_OPTS, /* struct flow_dissector_key_enc_opts */
>> >> >> >> >> 
>> >> >> >> >> I don't see the actual dissection implementation. Where is it?
>> >> >> >> >> Did you test the patchset?
>> >> >> >> >
>> >> >> >> >Yes, I did test it. But it is also possible something went astray along the
>> >> >> >> >way and I will retest.
>> >> >> >> >
>> >> >> >> >I think that the code you are looking for is in
>> >> >> >> >fl_classify() in this patch.
>> >> >> >> 
>> >> >> >> The dissection should be done in the flow_dissector. That's the whole
>> >> >> >> point in having it generic. You should move it there.
>> >> >> >
>> >> >> >Coming back to this after lunch, I believe what I have done in this patch
>> >> >> >is consistent with handling of other enc fields, which are set in
>> >> >> >fl_classify() rather than the dissector. In particular the ip_tunnel_info,
>> >> >> >which is used by this patch, is already used in fl_classify().
>> >> >> 
>> >> >> That means the current code is wrong. The dissection should be done in
>> >> >> flow_dissector, not in fl_classify.
>> >> >
>> >> >Would an better approach be to move the fl_classify() below into, say,
>> >> >skb_flow_dissect_tunnel_info() and call that from fl_classify().
>> >> 
>> >> No. There is one flow dissection function and you just set it up in a
>> >> way you need it. Makes no sense to me to split it up in any way.
>> >> 
>> >> 
>> >> >
>> >> >The reason I suggest this rather than moving the code into
>> >> >__skb_flow_dissect() is that currently flower assumes that tunnel_info
>> >> >is used if present. While I assume other users of () assume tunnel_info
>> >> >is not used even if present.
>> >> 
>> >> __skb_flow_dissect should look at what caller wants, then check skb_tunnel_info
>> >> only in case it is needed.
>> >
>> >Ok, do you think it is sufficient for __skb_flow_dissect to look at the
>> >tunnel keys, say FLOW_DISSECTOR_KEY_ENC_*? I am a bit concerned this may
>> >break flower as it look at the tunnel info unconditionally.
>> 
>> yeah. When flower needs that, it will get that from the flow dissector.
>> I don't see why it would break anything. Again, existing code is wrong:
>
>I understand that you think the existing code is wrong.
>But I also want to try not to add new bugs.
>
>I am concerned about the case where none of FLOW_DISSECTOR_KEY_ENC_* are
>set but flower currently dissects the tunnel info anyway. If I make
>dissection of tunnel info dependent on FLOW_DISSECTOR_KEY_ENC_*
>that may change things.

If none of FLOW_DISSECTOR_KEY_ENC_* are set, flower does not care about
the fields and therefore they are masked out by fl_set_masked_key.

Otherwise it would be a bug is flower would match on something user did
not specify.
