From: Guenter Roeck <linux@roeck-us.net>
Subject: [PATCH -next v3 1/2] device property: Return -ENXIO if there is no suitable FW interface
Date: Wed, 26 Aug 2015 20:27:04 -0700
Message-ID: <1440646025-18999-1-git-send-email-linux@roeck-us.net>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"Rafael J. Wysocki" <rafael.j.wysocki@intel.com>,
	Jeremy Linton <jeremy.linton@arm.com>, tony@atomide.com,
	Guenter Roeck <linux@roeck-us.net>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Steve Glendinning <steve.glendinning@shawell.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Return -ENXIO if device property array access functions don't find
a suitable firmware interface.

This lets drivers decide if they should use available platform data
instead.

Cc: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
v2: Added patch
v3: Document that device_property_read_string_array and
    device_property_read_string can also return -ENXIO.
    Move check if there is pset data, and thus detection if there is
    a suitable firmwawre interface, out of pset_prop_read_array into
    the calling code.

 drivers/base/property.c | 17 +++++++++++++----
 1 file changed, 13 insertions(+), 4 deletions(-)

diff --git a/drivers/base/property.c b/drivers/base/property.c
index 287704d680bf..caf937af98b3 100644
--- a/drivers/base/property.c
+++ b/drivers/base/property.c
@@ -156,6 +156,7 @@ EXPORT_SYMBOL_GPL(fwnode_property_present);
  *	   %-ENODATA if the property does not have a value,
  *	   %-EPROTO if the property is not an array of numbers,
  *	   %-EOVERFLOW if the size of the property is not as expected.
+ *	   %-ENXIO if no suitable firmware interface is present.
  */
 int device_property_read_u8_array(struct device *dev, const char *propname,
 				  u8 *val, size_t nval)
@@ -180,6 +181,7 @@ EXPORT_SYMBOL_GPL(device_property_read_u8_array);
  *	   %-ENODATA if the property does not have a value,
  *	   %-EPROTO if the property is not an array of numbers,
  *	   %-EOVERFLOW if the size of the property is not as expected.
+ *	   %-ENXIO if no suitable firmware interface is present.
  */
 int device_property_read_u16_array(struct device *dev, const char *propname,
 				   u16 *val, size_t nval)
@@ -204,6 +206,7 @@ EXPORT_SYMBOL_GPL(device_property_read_u16_array);
  *	   %-ENODATA if the property does not have a value,
  *	   %-EPROTO if the property is not an array of numbers,
  *	   %-EOVERFLOW if the size of the property is not as expected.
+ *	   %-ENXIO if no suitable firmware interface is present.
  */
 int device_property_read_u32_array(struct device *dev, const char *propname,
 				   u32 *val, size_t nval)
@@ -228,6 +231,7 @@ EXPORT_SYMBOL_GPL(device_property_read_u32_array);
  *	   %-ENODATA if the property does not have a value,
  *	   %-EPROTO if the property is not an array of numbers,
  *	   %-EOVERFLOW if the size of the property is not as expected.
+ *	   %-ENXIO if no suitable firmware interface is present.
  */
 int device_property_read_u64_array(struct device *dev, const char *propname,
 				   u64 *val, size_t nval)
@@ -252,6 +256,7 @@ EXPORT_SYMBOL_GPL(device_property_read_u64_array);
  *	   %-ENODATA if the property does not have a value,
  *	   %-EPROTO or %-EILSEQ if the property is not an array of strings,
  *	   %-EOVERFLOW if the size of the property is not as expected.
+ *	   %-ENXIO if no suitable firmware interface is present.
  */
 int device_property_read_string_array(struct device *dev, const char *propname,
 				      const char **val, size_t nval)
@@ -273,6 +278,7 @@ EXPORT_SYMBOL_GPL(device_property_read_string_array);
  *	   %-EINVAL if given arguments are not valid,
  *	   %-ENODATA if the property does not have a value,
  *	   %-EPROTO or %-EILSEQ if the property type is not a string.
+ *	   %-ENXIO if no suitable firmware interface is present.
  */
 int device_property_read_string(struct device *dev, const char *propname,
 				const char **val)
@@ -294,9 +300,11 @@ EXPORT_SYMBOL_GPL(device_property_read_string);
 	else if (is_acpi_node(_fwnode_)) \
 		_ret_ = acpi_dev_prop_read(to_acpi_node(_fwnode_), _propname_, \
 					   _proptype_, _val_, _nval_); \
-	else \
+	else if (is_pset(_fwnode_)) \
 		_ret_ = pset_prop_read_array(to_pset(_fwnode_), _propname_, \
 					     _proptype_, _val_, _nval_); \
+	else \
+		_ret_ = -ENXIO; \
 	_ret_; \
 })
 
@@ -434,9 +442,10 @@ int fwnode_property_read_string_array(struct fwnode_handle *fwnode,
 	else if (is_acpi_node(fwnode))
 		return acpi_dev_prop_read(to_acpi_node(fwnode), propname,
 					  DEV_PROP_STRING, val, nval);
-
-	return pset_prop_read_array(to_pset(fwnode), propname,
-				    DEV_PROP_STRING, val, nval);
+	else if (is_pset(fwnode))
+		return pset_prop_read_array(to_pset(fwnode), propname,
+					    DEV_PROP_STRING, val, nval);
+	return -ENXIO;
 }
 EXPORT_SYMBOL_GPL(fwnode_property_read_string_array);
 
-- 
2.1.4
