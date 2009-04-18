From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH 05/14] phylib: add *_direct() variants of phy_connect and
	phy_attach functions
Date: Sat, 18 Apr 2009 00:18:35 -0600
Message-ID: <fa686aa40904172318l55dba127jaf41b9c05186cc45@mail.gmail.com>
References: <20090331075537.1427.7819.stgit@localhost.localdomain>
	<20090331082709.1427.48689.stgit@localhost.localdomain>
	<FD808CF0-C694-4388-BBBE-B92367663F54@freescale.com>
	<fa686aa40904172308l38919bc0jfffbeb3a4106f582@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org, olof@lixom.net
To: Andy Fleming <afleming@freescale.com>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org>
In-Reply-To: <fa686aa40904172308l38919bc0jfffbeb3a4106f582@mail.gmail.com>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

On Sat, Apr 18, 2009 at 12:08 AM, Grant Likely
<grant.likely@secretlab.ca> wrote:
> On Wed, Apr 15, 2009 at 3:10 PM, Andy Fleming <afleming@freescale.com> wr=
ote:
>>
>> On Mar 31, 2009, at 3:27 AM, Grant Likely wrote:
>>
>>> From: Grant Likely <grant.likely@secretlab.ca>
>>>
>>> Add phy_connect_direct() and phy_attach_direct() functions so that
>>> drivers can use a pointer to the phy_device instead of trying to determ=
ine
>>> the phy's bus_id string.
>>>
>>> This patch is useful for OF device tree descriptions of phy devices whe=
re
>>> the driver doesn't need or know what the bus_id value in order to get a
>>> phy_device pointer.
>>>
>>> Signed-off-by: Grant Likely <grant.likely@secretlab.ca>
>>> ---
>>> @@ -312,18 +339,21 @@ struct phy_device * phy_connect(struct net_device
>>> *dev, const char *bus_id,
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0phy_interface_t interface)
>>> {
>>> =A0 =A0 =A0 =A0struct phy_device *phydev;
>>> + =A0 =A0 =A0 struct device *d;
>>> + =A0 =A0 =A0 int rc;
>>>
>>> - =A0 =A0 =A0 phydev =3D phy_attach(dev, bus_id, flags, interface);
>>> -
>>> - =A0 =A0 =A0 if (IS_ERR(phydev))
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return phydev;
>>> -
>>> - =A0 =A0 =A0 phy_prepare_link(phydev, handler);
>>> -
>>> - =A0 =A0 =A0 phy_start_machine(phydev, NULL);
>>> + =A0 =A0 =A0 /* Search the list of PHY devices on the mdio bus for the
>>> + =A0 =A0 =A0 =A0* PHY with the requested name */
>>> + =A0 =A0 =A0 d =3D bus_find_device_by_name(&mdio_bus_type, NULL, bus_i=
d);
>>> + =A0 =A0 =A0 if (!d) {
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_err("PHY %s not found\n", bus_id);
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ERR_PTR(-ENODEV);
>>> + =A0 =A0 =A0 }
>>> + =A0 =A0 =A0 phydev =3D to_phy_device(d);
>>>
>>> - =A0 =A0 =A0 if (phydev->irq > 0)
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 phy_start_interrupts(phydev);
>>> + =A0 =A0 =A0 rc =3D phy_attach_direct(dev, phydev, flags, interface);
>>> + =A0 =A0 =A0 if (rc)
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ERR_PTR(rc);
>>
>>
>> Why not just invoke phy_attach(), here, and thereby avoid the duplicate
>> search code?
>
> Yeah, you're right. =A0I had done it this way for symmetry, but calling
> phy_attach_direct is probably better.

Actually, no, my change is buggy.  I should be calling
phy_connect_direct() here, not phy_attach_direct().  Plus, either way
I do it there will be a few lines of duplicate code.  It will be fixed
in the next version.

g.

-- =

Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
