From: lucien xin <lucien.xin@gmail.com>
Subject: Re: [PATCH net v3] sctp: asconf's process should verify address
 parameter is in the beginning
Date: Thu, 27 Aug 2015 05:09:43 +0800
Message-ID: <CADvbK_eajEf2Hi_ysaH055g0VaVdMbuThg3At7e2JpkY9tHGLw@mail.gmail.com>
References: <a4904b1345d0e96667e8608454c225ae038acbbe.1440621325.git.lucien.xin@gmail.com>
	<55DE24AD.5090507@redhat.com>
	<20150826205925.GL1873@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Vlad Yasevich <vyasevic@redhat.com>,
	network dev <netdev@vger.kernel.org>,
	davem <davem@davemloft.net>
To: Marcelo Ricardo Leitner <mleitner@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f50.google.com ([209.85.218.50]:34996 "EHLO
	mail-oi0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750834AbbHZVJo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2015 17:09:44 -0400
Received: by oifo84 with SMTP id o84so3543939oif.2
        for <netdev@vger.kernel.org>; Wed, 26 Aug 2015 14:09:43 -0700 (PDT)
In-Reply-To: <20150826205925.GL1873@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 27, 2015 at 4:59 AM, Marcelo Ricardo Leitner
<mleitner@redhat.com> wrote:
> On Wed, Aug 26, 2015 at 04:42:21PM -0400, Vlad Yasevich wrote:
>> On 08/26/2015 04:35 PM, Xin Long wrote:
>> > in sctp_process_asconf(), we get address parameter from the beginning of
>> > the addip params. but we never check if it's really there. if the addr
>> > param is not there, it still can pass sctp_verify_asconf(), then to be
>> > handled by sctp_process_asconf(), it will not be safe.
>> >
>> > so add a code in sctp_verify_asconf() to check the address parameter is in
>> > the beginning, or return false to send abort.
>> >
>> > v2->v3:
>> >  * put the check in the loop, add the check for multiple address parameters.
>>
>>
>> Please split the multiple address detection from first address detection.
>> They are 2 different bugs and each one deserves a separate commit and
>> changelog.
>
> See below, thx.
>
>>
>> Thanks
>> -vlad
>>
>> > v1->v2:
>> >  * put the check behind the params' length verify.
>> >
>> > Signed-off-by: Xin Long <lucien.xin@gmail.com>
>> > Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
>> > ---
>> >  net/sctp/sm_make_chunk.c | 14 ++++++++++++--
>> >  1 file changed, 12 insertions(+), 2 deletions(-)
>> >
>> > diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
>> > index 06320c8..4068fe1 100644
>> > --- a/net/sctp/sm_make_chunk.c
>> > +++ b/net/sctp/sm_make_chunk.c
>> > @@ -3130,14 +3130,24 @@ bool sctp_verify_asconf(const struct sctp_association *asoc,
>> >             case SCTP_PARAM_ERR_CAUSE:
>> >                     break;
>> >             case SCTP_PARAM_IPV4_ADDRESS:
>> > +                   if (addr_param_seen) {
>> > +                           /* peer placed multiple address parameters into
>> > +                            * the same asconf. reject it.
>> > +                            */
>> > +                           return false;
>> > +                   }
>> >                     if (length != sizeof(sctp_ipv4addr_param_t))
>> >                             return false;
>> > -                   addr_param_seen = true;
>> > +                   if (param.v == addip->addip_hdr.params)
>> > +                           addr_param_seen = true;
>> >                     break;
>
> I know I had suggested using addr_param_seen to check for multiple
> occurrences, but now realized we can simplify this with something like:
>
> +                       if (param.v != addip->addip_hdr.params)
> +                               return false;
>                         addr_param_seen = true;
>
> Then the check against addr_param_seen is not needed and do both checks
> at once.
>
looks nice, Vlad ?
