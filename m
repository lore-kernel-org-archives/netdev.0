From: Gregory Haskins <ghaskins@novell.com>
Subject: Re: [RFC PATCH 01/17] shm-signal: shared-memory signals
Date: Tue, 31 Mar 2009 16:58:31 -0400
Message-ID: <49D283F7.7030508@novell.com>
References: <20090331184057.28333.77287.stgit@dev.haskins.net> <20090331184252.28333.70623.stgit@dev.haskins.net> <49D280C0.8010802@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigFA975C718AF72309F919826E"
Cc: linux-kernel@vger.kernel.org, agraf@suse.de, pmullaney@novell.com,
	pmorreale@novell.com, anthony@codemonkey.ws, rusty@rustcorp.com.au,
	netdev@vger.kernel.org, kvm@vger.kernel.org
To: Avi Kivity <avi@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from victor.provo.novell.com ([137.65.250.26]:34528 "EHLO
	victor.provo.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751850AbZCaU4T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2009 16:56:19 -0400
In-Reply-To: <49D280C0.8010802@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigFA975C718AF72309F919826E
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Avi Kivity wrote:
> Gregory Haskins wrote:
>> This interface provides a bidirectional shared-memory based signaling
>> mechanism.  It can be used by any entities which desire efficient
>> communication via shared memory.  The implementation details of the
>> signaling are abstracted so that they may transcend a wide variety
>> of locale boundaries (e.g. userspace/kernel, guest/host, etc).
>>
>> The shm_signal mechanism supports event masking as well as spurious
>> event delivery mitigation.
>> +
>> +/*
>> + *---------
>> + * The following structures represent data that is shared across
>> boundaries
>> + * which may be quite disparate from one another (e.g. Windows vs
>> Linux,
>> + * 32 vs 64 bit, etc).  Therefore, care has been taken to make sure
>> they
>> + * present data in a manner that is independent of the environment.
>> + *-----------
>> + */
>> +
>> +#define SHM_SIGNAL_MAGIC 0x58fa39df
>> +#define SHM_SIGNAL_VER   1
>> +
>> +struct shm_signal_irq {
>> +    __u8                  enabled;
>> +    __u8                  pending;
>> +    __u8                  dirty;
>> +};
>>  =20
>
> Some ABIs may choose to pad this, suggest explicit padding.

Yeah, good idea.  What is the official way to do this these days?  Are
GCC pragmas allowed?

>
>> +
>> +enum shm_signal_locality {
>> +    shm_locality_north,
>> +    shm_locality_south,
>> +};
>> +
>> +struct shm_signal_desc {
>> +    __u32                 magic;
>> +    __u32                 ver;
>> +    struct shm_signal_irq irq[2];
>> +};
>>  =20
>
> Similarly, this should be padded to 0 (mod 8).
Ack

>
> Instead of versions, I prefer feature flags which can be independently
> enabled or disabled.

Totally agreed.  If you look, most of the ABI has a type of "NEGCAP"
(negotiate capabilities) feature.  The version number is a contingency
plan in case I still have to break it for whatever reason.   I will
always opt for the feature bits over bumping the version when its
feasible (especially if/when this is actually in the field).

>
>> +
>> +/* --- END SHARED STRUCTURES --- */
>> +
>> +#ifdef __KERNEL__
>> +
>> +#include <linux/interrupt.h>
>> +
>> +struct shm_signal_notifier {
>> +    void (*signal)(struct shm_signal_notifier *);
>> +};
>>  =20
>
> This means "->inject() has been called from the other side"?

Yep
>
> (reading below I see this is so.  not used to reading well commented
> code... :)

:)

>
>> +
>> +struct shm_signal;
>> +
>> +struct shm_signal_ops {
>> +    int      (*inject)(struct shm_signal *s);
>> +    void     (*fault)(struct shm_signal *s, const char *fmt, ...);
>>  =20
>
> Eww.  Must we involve strings and printf formats?

This is still somewhat of a immature part of the design.  Its supposed
to be used so that by default, its a panic.  But on the host side, we
can do something like inject a machine-check.  That way malicious/broken
guests cannot (should not? ;) be able to take down the host.  Note today
I do not map this to anything other than the default panic, so this
needs some love.

But given the asynchronous nature of the fault, I want to be sure we
have decent accounting to avoid bug reports like "silent MCE kills the
guest" ;)  At least this way, we can log the fault string somewhere to
get a clue.

>
>> +    void     (*release)(struct shm_signal *s);
>> +};
>> +
>> +/*
>> + * signaling protocol:
>> + *
>> + * each side of the shm_signal has an "irq" structure with the
>> following
>> + * fields:
>> + *
>> + *    - enabled: controlled by shm_signal_enable/disable() to
>> mask/unmask
>> + *               the notification locally
>> + *    - dirty:   indicates if the shared-memory is dirty or clean.=20
>> This
>> + *               is updated regardless of the enabled/pending state
>> so that
>> + *               the state is always accurately tracked.
>> + *    - pending: indicates if a signal is pending to the remote local=
e.
>> + *               This allows us to determine if a
>> remote-notification is
>> + *               already in flight to optimize spurious
>> notifications away.
>> + */
>>  =20
>
> When you overlay a ring on top of this, won't the ring indexes convey
> the same information as ->dirty?

I agree that the information may be redundant with components of the
broader shm state.  However, we need this state at this level of scope
in order to function optimally, so I dont think its a huge deal to have
this here as well.  Afterall, the shm_signal library can only assess its
internal state.  We would have to teach it how to glean the broader
state through some mechanism otherwise (callback, perhaps), but I don't
think its worth it.

-Greg

>
>


--------------enigFA975C718AF72309F919826E
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.9 (GNU/Linux)
Comment: Using GnuPG with SUSE - http://enigmail.mozdev.org

iEYEARECAAYFAknSg/cACgkQlOSOBdgZUxktWQCfaKfeTHVAhTYOIKcYffTDJl6n
SwkAnjpue/Nw6bXk46LKhBHaELvGQ6Bj
=M5si
-----END PGP SIGNATURE-----

--------------enigFA975C718AF72309F919826E--
