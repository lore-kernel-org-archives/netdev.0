From: "Andonieh, Joe" <joe.andonieh@intel.com>
Subject: RE: RFC: Linux wireless extensions and WPA support
Date: Mon, 14 Jun 2004 11:56:03 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <386CBF9421521B41835E2BF21BEF80B89B6211@hasmsx402.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: "Jean Tourrilhes" <jt@hpl.hp.com>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
Content-class: urn:content-classes:message
To: "Jouni Malinen" <jkmaline@cc.hut.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


> These both can use the generic IE mechanism (SIOCSIWGENIE) to
configure
> Whatever mode is needed. I'm more used to doing the policy decision in
> user space (e.g., validating WPA/RSN IE in AssocReq), so there has not
> been much need in pushing all the information to the driver.

This depend where the AP implementation is as well as the management is
handled -- who will send the association failure or success, will you
divide the verification of the association between user and kernel
space? Moreover what if there is another feature that requires IE (let's
say for example WME) 

In both cases both the supplicant and the authenticator need to know
about the association. Authenticator need to track the .1x states and
the supplicant need to maintain contact for associated clients.


> Of course, we could change the IW_AUTH_ parameters for cipher and key
> Management suites to use bit field. This limits the number of options
to
> 32, but that should be enough and if not, can be extended in the
future.
> IW_AUTH_ALG_ is already doing this anyway and IW_AUTH_WPA_VERSION_ has
> Only two values, so it works as a bit field already (just needs to be
> Documented as such).

I Guess this is a better approach to have it as a bit mask -- Maybe I s
till do not understand the interface correctly, but still I can't see
how the user can set the pairwise cipher separately from the group
cipher? The interface show 
+/* IW_AUTH_PAIRWISE_CIPHER and IW_AUTH_GROUP_CIPHER values */
+#define IW_AUTH_CIPHER_NONE	0
+#define IW_AUTH_CIPHER_WEP40	1
+#define IW_AUTH_CIPHER_TKIP	2
+#define IW_AUTH_CIPHER_CCMP	4
+#define IW_AUTH_CIPHER_WEP104	5

But not specify which is what?



> The group cipher could be anything from WEP40 to CCMP and I want to be
> able to configure the client to reject APs that do not meet the
> current policy (which might be, "require CCMP"). Doing the selection
> only based on pairwise cipher would thus not be enough.

Maybe we need to add an interface to support both, for example group
cipher "Dint care" or "specified"??? Or even select from a group of
cipher, kind of allowed list. What do you think?

> Changing the IW_AUTH_ parameters to be bit fields would help here,
too,
> for the case of client drivers that want to do the WPA/RSN IE
processing
> in the driver instead of letting Supplicant take care of this.
Actually,
> this reminded me of another thing I forgot: we should add reporting of
> the exact IE that was used in (Re)AssocReq as a wireless event to the
> Supplicant so that this case of WPA/RSN IE being generated in the
> driver is supported.

We should have the capability for both, i.e. allow two kind of
implementations -- something similar to host AP where everything is
handled by the supplicant and also we need to allow the device handle
everything, this is sometimes depended on the device design and the
driver design the interface should not force it. Moreover we need to
think about additional features that require additional IE in the
association request which does not handled by the Security supplicant,
if we let the supplicant build the association request you do not want
it to build the IE for other features (such as WME)

I am more comfortable with an interface that allows user space (such as
supplicant to append IEs to the association/beacon/probs packets -- the
question is how to sync multiple management APPs and who will make the
decision for association success or failure.



Thanks
Joe

-----Original Message-----
From: Jouni Malinen [mailto:jm@jm.kir.nu] On Behalf Of Jouni Malinen
Sent: Sunday, June 13, 2004 11:12 PM
To: Andonieh, Joe
Cc: Jean Tourrilhes; netdev@oss.sgi.com
Subject: Re: RFC: Linux wireless extensions and WPA support

On Wed, Jun 09, 2004 at 09:23:23AM +0300, Andonieh, Joe wrote:

> 	Thinking about access point we need a way to set more than one
> cipher suite for the pairwise cipher list (for example mixed mode,
which
> have both TKIP and CCMP users.
> 
> Another aspect is an AP that wants to support more than one mode of
> operation, for example; advertise both WPA and RSN IE, or both WPA .1X
> and WPA PSK?

These both can use the generic IE mechanism (SIOCSIWGENIE) to configure
whatever mode is needed. I'm more used to doing the policy decision in
user space (e.g., validating WPA/RSN IE in AssocReq), so there has not
been much need in pushing all the information to the driver.

Of course, we could change the IW_AUTH_ parameters for cipher and key
management suites to use bit field. This limits the number of options to
32, but that should be enough and if not, can be extended in the future.
IW_AUTH_ALG_ is already doing this anyway and IW_AUTH_WPA_VERSION_ has
only two values, so it works as a bit field already (just needs to be
documented as such).

> From the Client Perspective; isn't it better Idea for the station
decide
> or match an access point to connect with depending on the pairwise
> cipher only? For example a client that supports CCMP can connect to
both
> access point where each one may be working in different mode, WPA --
> CCMP as both pair wise and group ciphers or with an AP in mixed mode
> which have CCMP as pairwise and TKIP as groupcast cipher.

The group cipher could be anything from WEP40 to CCMP and I want to be
able to configure the client to reject APs that do not meet the
current policy (which might be, "require CCMP"). Doing the selection
only based on pairwise cipher would thus not be enough.

Changing the IW_AUTH_ parameters to be bit fields would help here, too,
for the case of client drivers that want to do the WPA/RSN IE processing
in the driver instead of letting Supplicant take care of this. Actually,
this reminded me of another thing I forgot: we should add reporting of
the exact IE that was used in (Re)AssocReq as a wireless event to the
Supplicant so that this case of WPA/RSN IE being generated in the
driver is supported.

-- 
Jouni Malinen                                            PGP id EFC895FA
