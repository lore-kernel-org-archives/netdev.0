From: Joe Stringer <joestringernz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v2.44 1/5] odp: Allow VLAN actions after MPLS
	actions
Date: Tue, 22 Oct 2013 11:30:26 -0700
Message-ID: <CAOftzPgSG7NO+hFEeHU0xGH5TjJRe-THGDVz7THrm26j5ua-bA@mail.gmail.com>
References: <1381972511-27221-1-git-send-email-horms@verge.net.au>
	<1381972511-27221-2-git-send-email-horms@verge.net.au>
	<20131021204102.GD15986@nicira.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0485099311=="
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, Ravi K <rkerur-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Isaku Yamahata <yamahata-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
To: Ben Pfaff <blp-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20131021204102.GD15986-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

--===============0485099311==
Content-Type: multipart/alternative; boundary=047d7b874c922e778504e95898d4

--047d7b874c922e778504e95898d4
Content-Type: text/plain; charset=ISO-8859-1

You're quite right. I think for OF1.2, this is similar to existing
behaviour, but for OF1.3 it's just incorrect. There is an additional issue
with the LOAD action.

OF1.2:
"push_vlan(A),push_mpls,push_vlan(B)"
In OF1.2, this has the same result as:-
"push_mpls,push_vlan(A),push_vlan(B)"

When translated, this boils down to "(pop_vlan,)push_mpls,push_vlan(B)".
Correct me if I am wrong, but I think this is similar to the existing
behaviour, as we currently only support one layer of VLAN. It doesn't
matter if A == B.

OF1.3:
"mod_vlan_vid:A,push_mpls:0x8847,mod_vlan_vid:A" should work, but the
second mod_vlan is being dropped as it has the same VID as the first. This
is incorrect, as you point out.

LOAD:
"load:A->OXM_OF_VLAN_VID,push_mpls:0x8847,load:A->OXM_OF_VLAN_VID" doesn't
result in the correct vlan_vid from the first load action. I'm not sure
that vlan_tci_restore() is clear or correct---I believe its original
purpose was to properly handle the case where MPLS changes are made from
REG_LOAD and friends, in the way that the PUSH_MPLS case works. Instead, it
is handling all cases where MPLS actions have been applied in the past,
whether the current action modifies MPLS or not.

It's probably also worthwhile to make use of the ovs-ofctl monitor "-m"
option in the tests to actually verify these, rather than the current tests
where we just check the size of the resulting packet.

--047d7b874c922e778504e95898d4
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<p dir=3D"ltr">You&#39;re quite right. I think for OF1.2, this is similar t=
o existing behaviour, but for OF1.3 it&#39;s just incorrect. There is an ad=
ditional issue with the LOAD action.</p>
<p dir=3D"ltr">OF1.2:<br>
&quot;push_vlan(A),push_mpls,push_vlan(B)&quot;<br>
In OF1.2, this has the same result as:-<br>
&quot;push_mpls,push_vlan(A),push_vlan(B)&quot;</p>
<p dir=3D"ltr">When translated, this boils down to &quot;(pop_vlan,)push_mp=
ls,push_vlan(B)&quot;. Correct me if I am wrong, but I think this is simila=
r to the existing behaviour, as we currently only support one layer of VLAN=
. It doesn&#39;t matter if A =3D=3D B.</p>

<p dir=3D"ltr">OF1.3:<br>
&quot;mod_vlan_vid:A,push_mpls:0x8847,mod_vlan_vid:A&quot; should work, but=
 the second mod_vlan is being dropped as it has the same VID as the first. =
This is incorrect, as you point out.</p>
<p dir=3D"ltr">LOAD:<br>
&quot;load:A-&gt;OXM_OF_VLAN_VID,push_mpls:0x8847,load:A-&gt;OXM_OF_VLAN_VI=
D&quot; doesn&#39;t result in the correct vlan_vid from the first load acti=
on. I&#39;m not sure that=A0vlan_tci_restore() is clear or correct---I beli=
eve its original purpose was to properly handle the case where MPLS changes=
 are made from REG_LOAD and friends, in the way that the PUSH_MPLS case wor=
ks. Instead, it is handling all cases where MPLS actions have been applied =
in the past, whether the current action modifies MPLS or not.</p>

<p dir=3D"ltr">It&#39;s probably also worthwhile to make use of the ovs-ofc=
tl monitor &quot;-m&quot; option in the tests to actually verify these, rat=
her than the current tests where we just check the size of the resulting pa=
cket. </p>


--047d7b874c922e778504e95898d4--

--===============0485099311==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--===============0485099311==--
