From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 3/3] net: rxrpc: Replace time_t type with time64_t type
Date: Wed, 9 Aug 2017 17:12:58 +0200
Message-ID: <CAK8P3a2STbhgFB5kbVTZqAgY70K_GCaWgj6Kqs4RJOOt2oSd-g@mail.gmail.com>
References: <cover.1502246501.git.baolin.wang@linaro.org> <8ac57c96bf5a0695ecc67fd230440b0b9d15740f.1502246502.git.baolin.wang@linaro.org>
 <CAK8P3a2WU5uYddGrkWhyfNB4qTEDYne_pyCVG6n5b1w+vb1-OQ@mail.gmail.com>
 <6767.1502271233@warthog.procyon.org.uk> <CAK8P3a3L11rXAV8-hE1fNtAZyMBNnQneRm5g7F8VDmk7HjQV4A@mail.gmail.com>
 <11686.1502285205@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Baolin Wang <baolin.wang@linaro.org>,
        David Miller <davem@davemloft.net>, james.l.morris@oracle.com,
        "Serge E. Hallyn" <serge@hallyn.com>, marc.dionne@auristor.com,
        Dan Carpenter <dan.carpenter@oracle.com>,
        "Jason A. Donenfeld" <Jason@zx2c4.com>,
        Mark Brown <broonie@kernel.org>, keyrings@vger.kernel.org,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        LSM List <linux-security-module@vger.kernel.org>,
        Networking <netdev@vger.kernel.org>
To: David Howells <dhowells@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <11686.1502285205@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 9, 2017 at 3:26 PM, David Howells <dhowells@redhat.com> wrote:
> Arnd Bergmann <arnd@arndb.de> wrote:
>
>> Do you know which format is used in practice? Are both kad and k5 common
>> among rxrpc users?
>
> The aklog program I'm using uses the non-XDR interface to push a Kerberos 5
> ticket to the kernel, so it doesn't actually invoke rxrpc_preparse_xdr() from
> rxrpc_preparse().

Ah, I'm slowly starting to understand how this fits together. So you can add
a key either through key_add() from local user space, or through an rxrpc
socket.

>From what I can tell, the program you have at
http://people.redhat.com/~dhowells/rxrpc/klog.c will keep working beyond
2038 but not beyond 2106 on all 64-bit architectures and on those
32-bit systems that have a libc with 64-bit time_t. It could be modified
to use the xdr_rxk5 key format, which would make it use 64-bit time
values (and require the kernel fix mentioned above).

In contrast, the rxrpc socket interface would need a major rework to
support 64-bit expiration times. It receives a kerberos ticket with a
32-bit issue time
that gets used to calculate the expiry time in rxkad_decrypt_ticket, and from
there we pass it through a  rxrpc_key_data_v1 into key_instantiate_and_link(),
which calls rxrpc_preparse() and that just takes the expiry out again and sticks
it into another 32-bit field in struct rxkad_key, from where it
finally gets copied
into the (now 64-bit) key_preparsed_payload->expiry field.

Does my understanding match what you intended for the interfaces? Is there
a need to extend the rxrpc socket interface to support xdr_rxk5 keys as well?

         Arnd
