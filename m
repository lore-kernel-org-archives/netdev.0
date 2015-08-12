From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH 4/6] dlm: use sctp 1-to-1 API
Date: Wed, 12 Aug 2015 10:16:25 -0300
Message-ID: <55CB4729.2060203@gmail.com>
References: <cover.1439330654.git.marcelo.leitner@gmail.com>
 <479a4fd07289ea9043d84a27d706cccd2c968fb0.1439330654.git.marcelo.leitner@gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6D1CB794EB@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Vlad Yasevich <vyasevich@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	David Teigland <teigland@redhat.com>,
	"tan.hu@zte.com.cn" <tan.hu@zte.com.cn>
To: David Laight <David.Laight@ACULAB.COM>,
	"cluster-devel@redhat.com" <cluster-devel@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f178.google.com ([209.85.220.178]:34780 "EHLO
	mail-qk0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752589AbbHLNQd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2015 09:16:33 -0400
Received: by qkcs67 with SMTP id s67so4874236qkc.1
        for <netdev@vger.kernel.org>; Wed, 12 Aug 2015 06:16:33 -0700 (PDT)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CB794EB@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em 12-08-2015 07:23, David Laight escreveu:
> From: Marcelo Ricardo Leitner
>> Sent: 11 August 2015 23:22
>> DLM is using 1-to-many API but in a 1-to-1 fashion. That is, it's not
>> needed but this causes it to use sctp_do_peeloff() to mimic an
>> kernel_accept() and this causes a symbol dependency on sctp module.
>>
>> By switching it to 1-to-1 API we can avoid this dependency and also
>> reduce quite a lot of SCTP-specific code in lowcomms.c.
> ...
>
> You still need to enable sctp notifications (I think the patch deleted
> that code).
> Otherwise you don't get any kind of indication if the remote system
> 'resets' (ie sends an new INIT chunk) on an existing connection.

Right, it would miss the restart event and could generate a corrupted 
tx/rx buffers by glueing parts of old messages with new ones.

> It is probably enough to treat the MSG_NOTIFICATION as a fatal error
> and close the socket.

Just so we are on the same page, you mean that after accepting the new 
association and enabling notifications on it, any further notification 
on it can be treated as fatal errors, right? Seems reasonable to me.

> This is probably a bug in the sctp stack - if a connection is reset
> but the user hasn't requested notifications then it should be
> converted to a disconnect indication and a new incoming connection.

Maybe in such case resets shouldn't be allowed at all? Because unless it 
happens on a moment of silence it will always lead to application buffer 
corruption. Checked the RFCs now but couldn't find anything restricting 
them to some condition.

Thanks,
Marcelo
