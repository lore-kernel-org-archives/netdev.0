From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next 3/7] bpf: add array type of eBPF maps
Date: Tue, 4 Nov 2014 15:14:55 -0800
Message-ID: <CAMEtUuzZT8nTwA7mK3zDgmU=VSVe7UdTtj1h7nNdxc8wbWKruA@mail.gmail.com>
References: <1415069656-14138-1-git-send-email-ast@plumgrid.com>
	<1415069656-14138-4-git-send-email-ast@plumgrid.com>
	<5458A349.5020401@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Eric Dumazet <edumazet@google.com>,
	Linux API <linux-api@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5458A349.5020401@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 4, 2014 at 1:58 AM, Daniel Borkmann <dborkman@redhat.com> wrote:
>> +
>> +       memcpy(array->value + array->elem_size * index, value,
>> array->elem_size);
>
> What would protect this from concurrent updates?

nothing.
that's what I meant in commit log:
 - map_update_elem() replaces elements in an non-atomic way
   (for atomic updates hashtable type should be used instead)

The array map is like C array of structures.
Nothing protects concurrent access.
It's used in the cases where accuracy is not needed
or when there is no concurrent access.
To compute a histogram of events in tracing the array
of integers is used. Every integer is a counter. Program
increments it (may be without using xadd) and
user space periodically reads it back.
map_update_elem() is called by userspace once
to initialize it if zero-init is not enough.
Programs do lookup() and modify the values.
For array type update() method is used rarely,
delete() is never used and get_next() is needed
for completeness to browse maps through
common map API.
I'm guessing you're asking, because it may feel
that adding a lock() will help to make it more useful? ;)
It's not, since programs cannot take a lock().
