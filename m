From: Daniel Borkmann <danborkmann@iogearbox.net>
Subject: Re: [PATCH net] sctp: jsctp_sf_eat_sack: fix kernel NULL ptr dereference
Date: Fri, 14 Dec 2012 22:49:55 +0100
Message-ID: <CAD6jFUQtOL-4GAHvEJPw+zO1ZZ9Ay_qZGrfoirYdS3ONB0CYZA@mail.gmail.com>
References: <cover.1355494956.git.dborkman@redhat.com>
	<2813cf01509e495fee13ff1fab309f1186c0e57a.1355494956.git.dborkman@redhat.com>
	<50CB41F2.7040403@gmail.com>
	<50CB5A91.90404@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:41846 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932296Ab2LNVuD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Dec 2012 16:50:03 -0500
Received: from [78.46.5.203] (helo=sslproxy01.your-server.de)
	by www62.your-server.de with esmtpsa (TLSv1:AES256-SHA:256)
	(Exim 4.74)
	(envelope-from <danborkmann@iogearbox.net>)
	id 1Tjd8s-0006Mp-Dj
	for netdev@vger.kernel.org; Fri, 14 Dec 2012 22:50:02 +0100
Received: from [74.125.83.46] (helo=mail-ee0-f46.google.com)
	by sslproxy01.your-server.de with esmtpsa (TLS1.0:RSA_ARCFOUR_SHA1:16)
	(Exim 4.72)
	(envelope-from <danborkmann@iogearbox.net>)
	id 1Tjd8x-0002pd-5z
	for netdev@vger.kernel.org; Fri, 14 Dec 2012 22:50:07 +0100
Received: by mail-ee0-f46.google.com with SMTP id e53so2211690eek.19
        for <netdev@vger.kernel.org>; Fri, 14 Dec 2012 13:49:56 -0800 (PST)
In-Reply-To: <50CB5A91.90404@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 14, 2012 at 5:57 PM, Daniel Borkmann <dborkman@redhat.com> wrote:
> On 12/14/2012 04:12 PM, Vlad Yasevich wrote:
>> On 12/14/2012 09:27 AM, Daniel Borkmann wrote:
>>>
>>> During debugging a sctp problem, I hit a kernel NULL pointer
>>> dereference in the jprobes callback jsctp_sf_eat_sack(). This
>>> small patch fixes the panic.
>>>
>>> Cc: Vlad Yasevich <vyasevich@gmail.com>
>>> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
>>> ---
>>>   net/sctp/probe.c | 2 +-
>>>   1 file changed, 1 insertion(+), 1 deletion(-)
>>>
>>> diff --git a/net/sctp/probe.c b/net/sctp/probe.c
>>> index bc6cd75..0a4e9d6 100644
>>> --- a/net/sctp/probe.c
>>> +++ b/net/sctp/probe.c
>>> @@ -134,7 +134,7 @@ sctp_disposition_t jsctp_sf_eat_sack(const struct
>>> sctp_endpoint *ep,
>>>
>>>       sp = asoc->peer.primary_path;
>>>
>>> -    if ((full || sp->cwnd != lcwnd) &&
>>> +    if (sp && (full || sp->cwnd != lcwnd) &&
>>>           (!port || asoc->peer.port == port ||
>>>            ep->base.bind_addr.port == port)) {
>>>           lcwnd = sp->cwnd;
>>
>> Sorry, but this patch isn't making much sense.  @sp points to the primary
>> path of the association and that can not be null if we receiving
>> SACKs on this association.
>>
>> sctp_sf_eat_sack_6_2(), which we are probing, is only called while the
>> association is valid and all the transports still exist.  It is also called
>> under lock, so the transports can not go away while processing of the SACK.
>> So unless there is some kind of jprobe issue, the pointer
>> you are looking at should always be valid.
>
> Okay, I'll dig a bit deeper into that over the weekend.

That's just for the record, I'll do further tests / debugging tomorrow ...

I compiled the net kernel with kprobes selftest / sanity test
(kernel/test_kprobes.c) and it passed:

[    2.978082] Kprobe smoke test started
[    3.034014] Kprobe smoke test passed successfully

There, also jprobes are tested.
