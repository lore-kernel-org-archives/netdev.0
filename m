From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net 2/2] rhashtable: remove indirection for grow/shrink
 decision functions
Date: Wed, 25 Feb 2015 17:14:21 +0100
Message-ID: <54EDF4DD.1060709@iogearbox.net>
References: <cover.1424877322.git.daniel@iogearbox.net> <cd3e70163920753c7f1a492e6df253cff9b1b080.1424877322.git.daniel@iogearbox.net> <063D6719AE5E284EB5DD2968C1650D6D1CAED36D@AcuExch.aculab.com> <54EDEE55.8050605@iogearbox.net> <063D6719AE5E284EB5DD2968C1650D6D1CAED3A1@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "tgraf@suug.ch" <tgraf@suug.ch>,
	"pablo@netfilter.org" <pablo@netfilter.org>,
	"johunt@akamai.com" <johunt@akamai.com>,
	"kaber@trash.net" <kaber@trash.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:56328 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752941AbbBYQOh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2015 11:14:37 -0500
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CAED3A1@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/25/2015 04:51 PM, David Laight wrote:
> From: Daniel Borkmann [
>> On 02/25/2015 04:41 PM, David Laight wrote:
>> ...
>>> Why not cache the 'number of items before we need to expand' value
>>> after each expansion, setting it to 'infinite' when expansion is disabled.
>>> Then the above check is a simple comparison.
>>> You probably don't even need an atomic_read() - provided something is
>>> double checked once the first test determines that an expansion is needed.
>>
>> Did you read my cover letter? ;)
>
> I probably didn't infer the relevant references :-)
>
> Actually even if some code wanted other rules, provided they
> are based on comparing the 'number of items' to a preset limit
> the limit could be set during expansion/contraction.

The shift itself doesn't need to be atomic, if we store that in
the table directly instead of rhashtable, once on allocation it's
being set and can stay immutable during its table lifetime.

The nelems can be a percpu_counter where we have a batched sync
point and can make that dependent on the current table shift as
we don't need to be overly precise, we can just read the sync'ed
value. Currently, nelems are also being used by rhashtable users
outside of the core code to track if we are still allowed to
insert new elements, but I think we might also want to address
that at some point.
