From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH net] sctp: assign assoc_id earlier in __sctp_connect
Date: Fri, 4 Nov 2016 09:10:46 -0200
Message-ID: <dbeff034-f33a-8028-e325-6418029fb7d3@gmail.com>
References: <9df38dcd0323ad92386eb6851a60dc128dd00b4e.1478199530.git.marcelo.leitner@gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6DB0215215@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>,
        Vlad Yasevich <vyasevich@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        "syzkaller@googlegroups.com" <syzkaller@googlegroups.com>,
        "kcc@google.com" <kcc@google.com>,
        "glider@google.com" <glider@google.com>,
        "edumazet@google.com" <edumazet@google.com>,
        "dvyukov@google.com" <dvyukov@google.com>,
        "andreyknvl@google.com" <andreyknvl@google.com>
To: David Laight <David.Laight@ACULAB.COM>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:36595 "EHLO
        mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754820AbcKDLKx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Nov 2016 07:10:53 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DB0215215@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em 04-11-2016 08:55, David Laight escreveu:
> From: Of Marcelo Ricardo Leitner
>> Sent: 03 November 2016 19:04
>> sctp_wait_for_connect() currently already holds the asoc to keep it
>> alive during the sleep, in case another thread release it. But Andrey
>> Konovalov and Dmitry Vyukov reported an use-after-free in such
>> situation.
>>
>> Problem is that __sctp_connect() doesn't get a ref on the asoc and will
>> do a read on the asoc after calling sctp_wait_for_connect(), but by then
>> another thread may have closed it and the _put on sctp_wait_for_connect
>> will actually release it, causing the use-after-free.
>>
>> Fix is, instead of doing the read after waiting for the connect, do it
>> before so, and avoid this issue as the socket is still locked by then.
>> There should be no issue on returning the asoc id in case of failure as
>> the application shouldn't trust on that number in such situations
>> anyway.
>>
>> This issue doesn't exist in sctp_sendmsg() path.
>>
>> Reported-by: Dmitry Vyukov <dvyukov@google.com>
>> Reported-by: Andrey Konovalov <andreyknvl@google.com>
>> Tested-by: Andrey Konovalov <andreyknvl@google.com>
>> Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
>> ---
>>  net/sctp/socket.c | 7 +++++--
>>  1 file changed, 5 insertions(+), 2 deletions(-)
>>
>> diff --git a/net/sctp/socket.c b/net/sctp/socket.c
>> index 6cdc61c21438aa9b6dbdad93e70759071a4d6789..be1d9bb98230c9d77f676949db773b2dacd801a4 100644
>> --- a/net/sctp/socket.c
>> +++ b/net/sctp/socket.c
>> @@ -1214,9 +1214,12 @@ static int __sctp_connect(struct sock *sk,
>>
>>  	timeo = sock_sndtimeo(sk, f_flags & O_NONBLOCK);
>>
>> -	err = sctp_wait_for_connect(asoc, &timeo);
>> -	if ((err == 0 || err == -EINPROGRESS) && assoc_id)
>> +	if (assoc_id)
>>  		*assoc_id = asoc->assoc_id;
>> +	err = sctp_wait_for_connect(asoc, &timeo);
>> +	/* Note: the asoc may be freed after the return of
>> +	 * sctp_wait_for_connect.
>> +	 */
>
> Is it worth ensuring that *assoc_id is NULL on error?

I don't think so. An error was returned, the value shouldn't be trusted 
anyway and it's not leaking any sort of critical data.

Note that original code doesn't touch assoc_id in case of error. It's 
different than zeroing it out.

> Maybe change the code to:
> 	assoc_id_val = asoc->assoc_id;
> 	rval = sctp_wait_for_connect(asoc, &timeo);
> 	if (err != 0 && err != -EINPROGRESS)
> 		assoc_id_val = 0;
> 	if (assoc_id)
> 		*assoc_id = assoc_id_val;

Or just clear it in case of error..
  	if (assoc_id && (err != 0 && err != -EINPROGRESS))
  		*assoc_id = 0;
Amount of code is probably the same but avoids a temporary var.

   Marcelo
