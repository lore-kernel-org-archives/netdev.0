From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2] dns_resolver: assure that dns_query() result is
 null-terminated
Date: Sat, 7 Jun 2014 15:02:37 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1406071458520.24927@chino.kir.corp.google.com>
References: <CAHQdGtTtwS_DAXx-nhVjjO3D1wksuV+5br10gX0DheHzWDD+sw@mail.gmail.com> <1402167681-24676-1-git-send-email-manuel.schoelling@gmx.de> <alpine.DEB.2.02.1406071441050.24927@chino.kir.corp.google.com> <1402178010.4806.3.camel@schoellingm.dzne.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Manuel Schoelling <manuel.schoelling@gmx.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1402178010.4806.3.camel@schoellingm.dzne.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 7 Jun 2014, Manuel Schoelling wrote:

> > kzalloc() would be unnecessary overhead (zeroing definitely comes with a 
> > cost) if you're going to copy to the memory immediately afterwards.  Just 
> > leave the kmalloc(), do the memcpy() and explicitly zero terminate it 
> > _result.
> 
> Using kzalloc() was suggested of a developer on IRC (#kernelnewbies) but
> if you prefer kmalloc, that's ok, too.
> I'll send you a corrected patch in a second.
> 

Using kzalloc() here instead of kmalloc() is functionally equivalent to

	if (*_result) {
		memset(*_result, 0, len + 1);
		memcpy(*_result, upayload->data, len);
	}

so for anything with len > 1 there is an unnecessary overhead in doing 
this.  k?alloc() can return object sizes larger than len + 1 here as well 
(usually power-of-2 sizes are supported by the slab allocator) so 
depending on the value of len, you may be zeroing more memory than 
copying.

Your first patch had the right idea, it's just off by one.
