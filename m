From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net 2/3] sctp: hold transport before we access t->asoc
 in sctp proc
Date: Thu, 21 Jan 2016 11:27:36 -0800
Message-ID: <1453404456.1223.378.camel@edumazet-glaptop2.roam.corp.google.com>
References: <cover.1453398443.git.lucien.xin@gmail.com>
	 <9f366422b6a8c6c0c939ccbf993548c1881a2c16.1453398443.git.lucien.xin@gmail.com>
	 <4357f1f3ad90ffec1481a265d8ca198d75e25d07.1453398443.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Vlad Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net,
	davem@davemloft.net
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:34359 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750814AbcAUT1j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jan 2016 14:27:39 -0500
In-Reply-To: <4357f1f3ad90ffec1481a265d8ca198d75e25d07.1453398443.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-01-22 at 01:49 +0800, Xin Long wrote:
> Previously, before rhashtable, /proc assoc listing was done by
> read-locking the entire hash entry and dumping all assocs at once, so we
> were sure that the assoc wasn't freed because it wouldn't be possible to
> remove it from the hash meanwhile.
> 
> Now we use rhashtable to list transports, and dump entries one by one.
> That is, now we have to check if the assoc is still a good one, as the
> transport we got may be being freed.
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>
> ---
>  net/sctp/proc.c | 8 ++++++++
>  1 file changed, 8 insertions(+)
> 
> diff --git a/net/sctp/proc.c b/net/sctp/proc.c
> index 684c5b3..c74a810 100644
> --- a/net/sctp/proc.c
> +++ b/net/sctp/proc.c
> @@ -380,6 +380,8 @@ static int sctp_assocs_seq_show(struct seq_file *seq, void *v)
>  	}
>  
>  	transport = (struct sctp_transport *)v;

What protects you from this structure already being freed ?

> +	if (!sctp_transport_hold(transport))
> +		return 0;

If this is rcu, then you do not need to increment the refcount, and
decrement it later.
