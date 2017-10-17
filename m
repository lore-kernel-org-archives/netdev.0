From: Eric Dumazet <edumazet@google.com>
Subject: Re: [RFC] sctp: suspicious rcu_read_lock() in sctp_packet_config()
Date: Tue, 17 Oct 2017 10:20:58 -0700
Message-ID: <CANn89iKWrWnoVAu+KXhT-HLnGFme6ojKRCxwS5syrACiGVB1=g@mail.gmail.com>
References: <1508247956.31614.103.camel@edumazet-glaptop3.roam.corp.google.com>
 <CADvbK_dRBaOLzrXWS2ndHu3sz9LB87rJsyGog2BjishapiMhxw@mail.gmail.com>
 <20171017162826.GB5357@localhost.localdomain> <CANn89iKMBKJyLpdnUEER=9ot89P8yr4F0DGJABh1O=DCixdR8g@mail.gmail.com>
 <20171017170132.GC5357@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Xin Long <lucien.xin@gmail.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Vlad Yasevich <vyasevich@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        netdev <netdev@vger.kernel.org>, Wei Wang <weiwan@google.com>,
        linux-sctp@vger.kernel.org
To: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f174.google.com ([209.85.216.174]:46985 "EHLO
        mail-qt0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757622AbdJQRU7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 13:20:59 -0400
Received: by mail-qt0-f174.google.com with SMTP id 1so5166433qtn.3
        for <netdev@vger.kernel.org>; Tue, 17 Oct 2017 10:20:59 -0700 (PDT)
In-Reply-To: <20171017170132.GC5357@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 17, 2017 at 10:01 AM, Marcelo Ricardo Leitner
<marcelo.leitner@gmail.com> wrote:
> On Tue, Oct 17, 2017 at 09:44:10AM -0700, Eric Dumazet wrote:
>> On Tue, Oct 17, 2017 at 9:28 AM, Marcelo Ricardo Leitner
>> <marcelo.leitner@gmail.com> wrote:
>> > On Tue, Oct 17, 2017 at 11:31:30PM +0800, Xin Long wrote:
>> >> On Tue, Oct 17, 2017 at 9:45 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> >> > SCTP experts.
>> >> >
>> >> > syszkaller reported a few crashes in sctp_packet_config() with invalid
>> >> > access to a deleted dst.
>> >> >
>> >> > The rcu_read_lock() in sctp_packet_config() is suspect.
>> >> >
>> >> > It does not protect anything at the moment.
>> >> >
>> >> > If we expect tp->dst to be manipulated/changed by another cpu/thread,
>> >> > then we need proper rcu protection.
>> >> >
>> >> > Following patch to show what would be a minimal change (but obviously
>> >> > bigger changes are needed, like sctp_transport_pmtu_check() and
>> >> > sctp_transport_dst_check(), and proper sparse annotations)
>> >> will check all places accessing tp->dst in sctp.
>> >
>> > I checked some and sctp_transport_dst_check() should be fine because
>> > by then we are holding a reference on dst. Same goes to
>> > sctp_transport_pmtu_check().
>>
>> Really ?
>>
>
> Yes,
>
>> What about sctp_v4_err() -> sctp_icmp_redirect() -> sctp_transport_dst_check()
>>
>> It seems quite possible that the BH handler can access it, while
>> socket is owned by user.
>
> hidden here:
> sctp_v4_err() {
> ...
>         sk = sctp_err_lookup(net, AF_INET, skb, sctp_hdr(skb), &asoc,
>         &transport);
> ...
> out_unlock:
>         sctp_err_finish(sk, transport);
> }
>
> sctp_err_lookup() {
> ...
>         bh_lock_sock(sk);
>
>         /* If too many ICMPs get dropped on busy
>          * servers this needs to be solved differently.
>          */
>         if (sock_owned_by_user(sk))            [A]
>                 __NET_INC_STATS(net, LINUX_MIB_LOCKDROPPEDICMPS);
>
>         *app = asoc;
>         *tpp = transport;
>         return sk;
> ...
> }
>
> Though that if() on [A] should be bailing out without returning
> nothing. That's a bug. More like:
>
>         if (sock_owned_by_user(sk)) {
>                 __NET_INC_STATS(net, LINUX_MIB_LOCKDROPPEDICMPS);
>                 goto out;
>         }
>

So why sctp_v4_err() is doing this test ?

if (!sock_owned_by_user(sk) && inet->recverr) {

It looks like socket can be owned by the user, and [A] check only
increments an SNMP counter,
that wont help to solve the tp->dst use after free.



I
