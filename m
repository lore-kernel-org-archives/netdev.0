From: Mathias Krause <minipli@googlemail.com>
Subject: Re: [PATCH 5/6] xfrm_user: ensure user supplied esn replay window is valid
Date: Thu, 20 Sep 2012 08:12:11 +0200
Message-ID: <CA+rthh8Q464Jw5okH5aXds0QZztay9dpcyniahtWFxev8tpN9w@mail.gmail.com>
References: <1348090423-32665-1-git-send-email-minipli@googlemail.com>
	<1348090423-32665-6-git-send-email-minipli@googlemail.com>
	<1348094309.2636.80.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Martin Willi <martin@revosec.ch>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1348094309.2636.80.camel@bwh-desktop.uk.solarflarecom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 20, 2012 at 12:38 AM, Ben Hutchings
<bhutchings@solarflare.com> wrote:
> On Wed, 2012-09-19 at 23:33 +0200, Mathias Krause wrote:
>> The current code fails to ensure that the netlink message actually
>> contains as many bytes as the header indicates. If a user creates a new
>> state or updates an existing one but does not supply the bytes for the
>> whole ESN replay window, the kernel copies random heap bytes into the
>> replay bitmap, the ones happen to follow the XFRMA_REPLAY_ESN_VAL
>> netlink attribute. This leads to following issues:
>>
>> 1. The replay window has random bits set confusing the replay handling
>>    code later on.
>>
>> 2. A malicious user could use this flaw to leak up to ~3.5kB of heap
>>    memory when she has access to the XFRM netlink interface (requires
>>    CAP_NET_ADMIN).
>
> Where does this limit come from?  Is that just the standard size netlink
> skb?

It's from then "msg_new(NLMSG_DEFAULT_SIZE, GFP_ATOMIC)" in
xfrm_state_netlink() which boils down to roughly 3.7k free space for
the netlink message. Excluding the space used for struct
xfrm_usersa_info and some minimal extensions leaves roughly 3.5k for
the replay window.
Maybe that's just another bug and the code should allocate a netlink
message big enough for the whole state dump. Don't know. I'm not
familiar with the code.

> I'm a little worried that the user-provided
> xfrm_replay_state_esn::bmp_len is not being directly validated anywhere.

That's what my P.S. in the cover letter tried to hint at -- a missing
upper limit check. But as I wanted to avoid lengthy discussions about
the concrete value and the possible need for some sysctl knob to tune
this even further, I just left this as an exercise for someone else
who is more familiar with the code ;)

> Currently xfrm_replay_state_esn_len() may overflow, and as its return
> type is int it may unexpectedly return a negative value.

So xfrm_replay_state_esn_len() should return size_t instead as it's
value should always be positive -- it represents a length. Negative
lengths make no sense. It can overflow, still. But it cannot get
negative, at least. Still, the upper limit check would be required to
avoid other user induced nastiness.

>
> [...]
>> --- a/net/xfrm/xfrm_user.c
>> +++ b/net/xfrm/xfrm_user.c
> [...]
>> @@ -370,14 +378,15 @@ static inline int xfrm_replay_verify_len(struct xfrm_replay_state_esn *replay_es
>>                                        struct nlattr *rp)
>>  {
>>       struct xfrm_replay_state_esn *up;
>> +     size_t ulen;
>
> I would normally expect to see sizes declared as size_t but mixing
> size_t and int in comparisons tends to result in bugs.  So I think this
> should to be int, matching the return types of nla_len() and
> xfrm_replay_state_esn_len() (and apparently all lengths in netlink...)

I disagree. The value of nla_len() is ensured to be in the range of
[sizeof(*up), USHRT_MAX-NLA_HDRLEN], i.e. a positive 16 bit number,
when it passes nlmsg_parse() in xfrm_user_rcv_msg(). This in turn
allows us to assume the int value returned by nla_len() is actually
positive and the compiler can safely make it unsigned for the compare
-- no sign bit, no hassle.
What still might happen is the overflow in xfrm_replay_state_esn_len()
resulting in a to small bitmap allocation for the requested replay
size. But that gets catched in xfrm_init_replay(). Little late, but
hey.

>
>>       if (!replay_esn || !rp)
>>               return 0;
>>
>>       up = nla_data(rp);
>> +     ulen = xfrm_replay_state_esn_len(up);
>>
>> -     if (xfrm_replay_state_esn_len(replay_esn) !=
>> -                     xfrm_replay_state_esn_len(up))
>> +     if (nla_len(rp) < ulen || xfrm_replay_state_esn_len(replay_esn) != ulen)
>>               return -EINVAL;
>>
>>       return 0;
>> @@ -388,22 +397,28 @@ static int xfrm_alloc_replay_state_esn(struct xfrm_replay_state_esn **replay_esn
>>                                      struct nlattr *rta)
>>  {
>>       struct xfrm_replay_state_esn *p, *pp, *up;
>> +     size_t klen, ulen;
>
> Also int, for the same reason.

No, for the reason stated above. I'll fixup
xfrm_replay_state_esn_len() to return size_t instead.

>
>>       if (!rta)
>>               return 0;
>>
>>       up = nla_data(rta);
>> +     klen = xfrm_replay_state_esn_len(up);
>> +     ulen = nla_len(rta) > sizeof(*up) ? klen : sizeof(*up);
> [...]
>
> I understand that this is correct since verify_replay() previously
> checked that nla_len(rta) is either == sizeof(*up) or >= klen.  But
> would it not be more obviously correct to test nla_len(rta) >= klen?

It is. Comparing against klen makes the code more readable.

Thanks,
Mathias

>
> Ben.
>
> --
> Ben Hutchings, Staff Engineer, Solarflare
> Not speaking for my employer; that's the marketing department's job.
> They asked us to note that Solarflare product names are trademarked.
>
