From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [PATCH net] sctp: sctp_addr_id2transport should verify the addr
 before looking up assoc
Date: Wed, 25 Jan 2017 23:34:33 +0800
Message-ID: <CADvbK_dw2XhYF7bc8PdyuBG2WgzNwZxJekwWsc36UN=2QE8MDg@mail.gmail.com>
References: <2ba9d3e0b3aa05baa3791811c92248126d233c67.1485237713.git.lucien.xin@gmail.com>
 <CAGCdqXEAkbeMPhVA5N_vYV_k_54faX_0JWui5kSrZBbsmms7jg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: network dev <netdev@vger.kernel.org>,
        "linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>
To: Vladislav Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:35809 "EHLO
        mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751838AbdAYPep (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2017 10:34:45 -0500
In-Reply-To: <CAGCdqXEAkbeMPhVA5N_vYV_k_54faX_0JWui5kSrZBbsmms7jg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 25, 2017 at 11:27 PM, Vladislav Yasevich
<vyasevich@gmail.com> wrote:
> On Tue, Jan 24, 2017 at 1:01 AM, Xin Long <lucien.xin@gmail.com> wrote:
>>
>> sctp_addr_id2transport is a function for sockopt to look up assoc by
>> address. As the address is from userspace, it can be a v4-mapped v6
>> address. But in sctp protocol stack, it always handles a v4-mapped
>> v6 address as a v4 address. So it's necessary to convert it to a v4
>> address before looking up assoc by address.
>>
>> This patch is to fix it by calling sctp_verify_addr in which it can do
>> this conversion before calling sctp_endpoint_lookup_assoc, just like
>> what sctp_sendmsg and __sctp_connect do for the address from users.
>>
>> Signed-off-by: Xin Long <lucien.xin@gmail.com>
>> ---
>>  net/sctp/socket.c | 6 +++++-
>>  1 file changed, 5 insertions(+), 1 deletion(-)
>>
>> diff --git a/net/sctp/socket.c b/net/sctp/socket.c
>> index 318c678..37eeab7 100644
>> --- a/net/sctp/socket.c
>> +++ b/net/sctp/socket.c
>> @@ -235,8 +235,12 @@ static struct sctp_transport
>> *sctp_addr_id2transport(struct sock *sk,
>>                                               sctp_assoc_t id)
>>  {
>>         struct sctp_association *addr_asoc = NULL, *id_asoc = NULL;
>> -       struct sctp_transport *transport;
>> +       struct sctp_af *af = sctp_get_af_specific(addr->ss_family);
>>         union sctp_addr *laddr = (union sctp_addr *)addr;
>> +       struct sctp_transport *transport;
>> +
>> +       if (sctp_verify_addr(sk, laddr, af->sockaddr_len))
>> +               return NULL;
>>
>
> This causes a side-effect such that GET options will end up with ipv4
> address instead
> of a v4mapped address that was passed in.
not really

(more below)
>
> -vlad
>
>>
>>         addr_asoc = sctp_endpoint_lookup_assoc(sctp_sk(sk)->ep,
>>                                                laddr,
        sctp_get_pf_specific(sk->sk_family)->addr_to_user(sctp_sk(sk),
                                                (union sctp_addr *)addr);

here it will convert it back to v4mapped v6 address.

>> --
>> 2.1.0
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
