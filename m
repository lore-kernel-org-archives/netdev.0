From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2] dns_resolver: assure that dns_query() result is
 null-terminated
Date: Sat, 7 Jun 2014 14:42:59 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1406071441050.24927@chino.kir.corp.google.com>
References: <CAHQdGtTtwS_DAXx-nhVjjO3D1wksuV+5br10gX0DheHzWDD+sw@mail.gmail.com> <1402167681-24676-1-git-send-email-manuel.schoelling@gmx.de>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="531381512-1747437259-1402177381=:24927"
Cc: davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: =?UTF-8?Q?Manuel_Sch=C3=B6lling?= <manuel.schoelling@gmx.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1402167681-24676-1-git-send-email-manuel.schoelling@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--531381512-1747437259-1402177381=:24927
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: 8BIT

On Sat, 7 Jun 2014, Manuel Schölling wrote:

> dns_query() credulously assumes that keys are null-terminated and
> returns a copy of a memory block that is off by one.

No sign-off?  Please read Documentation/SubmittingPatches.

> ---
>  net/dns_resolver/dns_query.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/dns_resolver/dns_query.c b/net/dns_resolver/dns_query.c
> index e7b6d53..84871a2 100644
> --- a/net/dns_resolver/dns_query.c
> +++ b/net/dns_resolver/dns_query.c
> @@ -145,11 +145,11 @@ int dns_query(const char *type, const char *name, size_t namelen,
>  	len = upayload->datalen;
>  
>  	ret = -ENOMEM;
> -	*_result = kmalloc(len + 1, GFP_KERNEL);
> +	*_result = kzalloc(len + 1, GFP_KERNEL);
>  	if (!*_result)
>  		goto put;
>  
> -	memcpy(*_result, upayload->data, len + 1);
> +	memcpy(*_result, upayload->data, len);
>  	if (_expiry)
>  		*_expiry = rkey->expiry;
>  

kzalloc() would be unnecessary overhead (zeroing definitely comes with a 
cost) if you're going to copy to the memory immediately afterwards.  Just 
leave the kmalloc(), do the memcpy() and explicitly zero terminate it 
_result.
--531381512-1747437259-1402177381=:24927--
