From: Yuchung Cheng <ycheng@google.com>
Subject: Re: IPv6 kernel warning
Date: Tue, 8 Oct 2013 10:56:54 -0700
Message-ID: <CAK6E8=dXS7cbjxp=GwmH_JROOFvU_Yp9YnTn0diHT5A4WWkhQQ@mail.gmail.com>
References: <20130920131153.GF12758@n2100.arm.linux.org.uk>
 <20130920160830.GA4241@marquez.int.rhx> <CAK6E8=eNFG0fic+NYeQBjEoUQMeZKSAT3LU0JSQyE-4i_cDaZQ@mail.gmail.com>
 <alpine.DEB.2.02.1310071111240.17658@dtop> <CAK6E8=czoej81t=-J=gjjyQiGVbZ0qiNKBbeRVSWYtweXfSRNQ@mail.gmail.com>
 <CADVnQynJVvFesFYp68N5kzCJJD3-NXPZUUMfkg8m=or4eaLzMQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: dormando <dormando@rydia.net>,
	Michele Baldessari <michele@acksyn.org>,
	Russell King - ARM Linux <linux@arm.linux.org.uk>,
	netdev <netdev@vger.kernel.org>,
	Nandita Dukkipati <nanditad@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:34636 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755531Ab3JHR5Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Oct 2013 13:57:16 -0400
Received: by mail-ie0-f169.google.com with SMTP id tp5so20340550ieb.14
        for <netdev@vger.kernel.org>; Tue, 08 Oct 2013 10:57:15 -0700 (PDT)
In-Reply-To: <CADVnQynJVvFesFYp68N5kzCJJD3-NXPZUUMfkg8m=or4eaLzMQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 8, 2013 at 7:05 AM, Neal Cardwell <ncardwell@google.com> wrote:
> On Mon, Oct 7, 2013 at 3:51 PM, Yuchung Cheng <ycheng@google.com> wrote:
>> I suspect tcp_process_tlp_ack() should not revert state to Open
>> directly, but calling tcp_try_keep_open() instead, similar to all the
>> undo processing in the tcp_fastretrans_alert(): after
>> tcp_end_cwnd_reduction(), the process (E) falls back to check other
>> stats before moving to CA_Open.
>>
>>
>> index 9c62257..9012b42 100644
>> --- a/net/ipv4/tcp_input.c
>> +++ b/net/ipv4/tcp_input.c
>> @@ -3314,7 +3314,7 @@ static void tcp_process_tlp_ack(struct sock *sk, u32 ack,
>>                         tcp_init_cwnd_reduction(sk, true);
>>                         tcp_set_ca_state(sk, TCP_CA_CWR);
>>                         tcp_end_cwnd_reduction(sk);
>> -                       tcp_set_ca_state(sk, TCP_CA_Open);
>> +                       tcp_try_keep_open(sk);
>>                         NET_INC_STATS_BH(sock_net(sk),
>>                                          LINUX_MIB_TCPLOSSPROBERECOVERY);
>>                 }
>
> Yes, nice catch! This looks good to me. My testing confirms that this
> definitely fixes a bug when this code fires and there are segments
> SACKed out. Since it will stay in CA_Disorder if there are outstanding
> retransmissions, I bet it will also fix the WARN_ON(tp->retrans_out !=
> 0) in state TCP_CA_Open that people are seeing.
Sounds good. Let me do more tests then I will submit a bug fix.

>
> neal
